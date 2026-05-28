---
name: create-global-ipd-attribute
description: Create a new IPD (In-Product Discovery) attribute provider hook for targeting in the Recommendations widget. Use when the user wants to add new attributes to IPD, add targeting data to the recommendations widget, create a new useIPDAttributes provider, or mentions IPD attributes.
---
# Add New IPD Attribute Provider

Add a new set of targeting attributes to the IPD (In-Product Discovery) widget by creating a **provider hook**.

The `useIPDAttributes` hook aggregates data from multiple self-contained providers. Each provider returns a `PromiseRef` that resolves with its attributes (or `undefined` to opt out). The resolver merges all fulfilled results and exposes `isAttributesReady` + `result` to the consuming component.

> **Important:** `usePromiseRef` is **resolve-only** — there is no `reject` method. On errors, providers must call `promise.resolve(undefined)` after logging the error. This prevents unhandled promise rejections and cascading test failures, while still allowing graceful degradation. Errors are logged at the point of failure so visibility is not lost.

## When the user asks to:
- Add a new attribute or targeting to IPDs
- Create a new IPD attribute provider
- Send experiment, feature flag, or API data to the recommendations widget
- Add data to the IPD global ui payload
- Onboard a new data source for IPD targeting

## Required Information

Before starting, the user must provide the following. If any are missing, **ask before proceeding**:

1. **Attribute name(s) and types** -- what fields should the provider resolve with?
2. **Data source** -- where does the data come from? (API endpoint/client, experiment, cookie, flag, etc.)
3. **Feature flag** -- is there a gating flag? If so, what is its name? (If it doesn't exist yet, the agent should add it to `config/flags.ini`)
4. **Provider name** -- a descriptive hook name, or enough context to derive one (e.g., `useNoCCTrialProvider`)

## Steps

### 1. Create Your Provider

Create a new file at `web/js/src/Recommendations/hooks/providers/useYourProvider.ts`.

Every provider must:
- Call `usePromiseRef<T>()` to get a stable, externally-resolvable promise
- Resolve with your attribute object, or `undefined` when attributes should be excluded (e.g., flag is off)
- **Ensure every code path resolves the promise** -- an unresolved promise will block `isAttributesReady` indefinitely since the resolver uses `Promise.allSettled`. On errors, resolve with `undefined` (never reject)
- **Wrap async fetches with `createCachedRequest`** if the underlying client doesn't already cache. Provider hooks can be invoked multiple times across renders/components; only the first `PromiseRef` resolves, but the network call still fires. `createCachedRequest` deduplicates in-flight requests and caches results with a configurable TTL (default 60s). Instantiate it at **module scope** (outside the hook) so the cache persists across hook invocations:
  ```typescript
  import { createCachedRequest } from '../../lib/createCachedRequest';
  const myRequest = createCachedRequest(fetchMyData); // module-level singleton
  ```
- Return `promise.ref()`

Pick the pattern that matches your data source:

#### Pattern A: Synchronous (cookies, static data)

```typescript
import { usePromiseRef, type PromiseRef } from '../usePromiseRef';

export type MyAttributes = {
  myField: boolean;
};

export const useMyProvider = (): PromiseRef<MyAttributes> => {
  const promise = usePromiseRef<MyAttributes>();

  promise.resolve({ myField: true });

  return promise.ref();
};
```

#### Pattern B: Experiment

```typescript
import { isOn } from '@mc/flags';
import { PENDING_VARIANT, useExperiment } from '@mc/experiments';
import { usePromiseRef, type PromiseRef } from '../usePromiseRef';

export type MyExpAttributes = {
  isInMyControl: boolean;
  isInMyVariant: boolean;
};

export const useMyExpProvider = (): PromiseRef<MyExpAttributes | undefined> => {
  const promise = usePromiseRef<MyExpAttributes | undefined>();
  const experiment = useExperiment('my-experiment-name');

  if (!isOn(FLAGS.MY_FEATURE_FLAG)) {
    promise.resolve(undefined);
  } else if (experiment !== PENDING_VARIANT) {
    promise.resolve({
      isInMyControl: experiment === 'my-experiment-control',
      isInMyVariant: experiment === 'my-experiment-variant',
    });
  }

  return promise.ref();
};
```

#### Pattern C: Async API

```typescript
import { useEffect } from 'react';
import { isOn } from '@mc/flags';
import { fetchMyData } from '@mc/api/MyApi';
import { createCachedRequest } from '../../lib/createCachedRequest';
import logger from '../../components/logger';
import { usePromiseRef, type PromiseRef } from '../usePromiseRef';

export type MyAsyncAttributes = {
  fieldOne: string | null;
  fieldTwo: number | null;
};

const myRequest = createCachedRequest(fetchMyData);

export const useMyAsyncProvider = (): PromiseRef<MyAsyncAttributes | undefined> => {
  const promise = usePromiseRef<MyAsyncAttributes | undefined>();

  useEffect(() => {
    if (!isOn(FLAGS.MY_FEATURE_FLAG)) {
      promise.resolve(undefined);
      return;
    }

    myRequest
      .fetch()
      .then((response) => {
        promise.resolve({
          fieldOne: response.fieldOne ?? null,
          fieldTwo: response.fieldTwo ?? null,
        });
      })
      .catch((error: Error) => {
        logger('Error fetching my data for IPD targeting', {
          error: error?.message,
        });
        promise.resolve(undefined);
      });
  }, []);

  return promise.ref();
};
```

---

### 2. Register in `useIPDAttributes.ts`

**File:** `web/js/src/Recommendations/hooks/useIPDAttributes.ts`

Four changes in this file:

```typescript
// (a) Import your provider hook and type
import {
  useMyProvider,
  type MyAttributes,
} from './providers/useMyProvider';

// (b) Add your type to the IPDAttributes intersection
type IPDAttributes = McAnonIdAttributes &
  MyAttributes &  // <-- add here (alphabetical)
  NoCCTrialAttributes &
  // ...

// (c) Invoke your hook inside useIPDAttributes
const myPromise = useMyProvider();

// (d) Add the promise to the resolver array
return useIPDAttributesResolver<IPDAttributes>(
  [
    mcAnonIdPromise,
    myPromise,  // <-- add here (alphabetical)
    noCCTrialPromise,
    // ...
  ],
  attributesFromProps,
);
```

That's it. The resolver handles caching, aggregation, error handling, and pub/sub automatically.

---

### 3. Add Tests

Create `web/js/src/Recommendations/hooks/providers/useMyProvider.test.ts`.

Providers are tested as hooks via `renderHook`. The returned `result.current` is a promise you assert against directly. Keep tests minimal -- one test per meaningful code branch (flag off, success, error). Do not add redundant or overly verbose test cases.

```typescript
import { renderHook } from '@testing-library/react';
import { isOn } from '@mc/flags';
import { useMyProvider } from './useMyProvider';

jest.mock('@mc/flags');

const mockIsOn = isOn as jest.Mock;

describe('useMyProvider', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('resolves undefined when flag is off', async () => {
    mockIsOn.mockReturnValue(false);

    const { result } = renderHook(() => useMyProvider());

    await expect(result.current).resolves.toBeUndefined();
  });

  it('resolves with attributes when flag is on', async () => {
    mockIsOn.mockReturnValue(true);
    // ... mock your data source ...

    const { result } = renderHook(() => useMyProvider());

    await expect(result.current).resolves.toEqual({
      fieldOne: 'expected',
      fieldTwo: 42,
    });
  });

  // For async providers: test the error case (resolves undefined, not rejects)
  it('resolves undefined when API call fails', async () => {
    mockIsOn.mockReturnValue(true);
    // ... mock rejection ...

    const { result } = renderHook(() => useMyProvider());

    await expect(result.current).resolves.toBeUndefined();
  });
});
```

Run tests:
```bash
npm run test -- --testPathPattern="useMyProvider.test.ts"
```

---

## Files to Modify

1. **`hooks/providers/useMyProvider.ts`** -- new provider hook
2. **`hooks/providers/useMyProvider.test.ts`** -- new provider tests
3. **`hooks/useIPDAttributes.ts`** -- import, type, invocation, and resolver array

---

## Checklist

- [ ] Provider created with `usePromiseRef` in `hooks/providers/`
- [ ] Resolves `undefined` when gating flag is off (if applicable)
- [ ] Attribute type exported from provider file
- [ ] Type added to `IPDAttributes` intersection in `useIPDAttributes.ts`
- [ ] Hook invoked in `useIPDAttributes` and promise added to resolver array
- [ ] Test file covers: flag off, flag on/success, and error cases (error resolves `undefined`, not rejects)
- [ ] All tests pass

---

## Need Help?

- Slack: #mc-c1c-eng (ping @mc-c1c-oncall)
- Existing providers in `hooks/providers/` serve as living examples
