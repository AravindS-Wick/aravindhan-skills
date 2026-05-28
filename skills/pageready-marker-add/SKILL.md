---
name: pageready-marker-add
description: Place the markPageReadyEnd() performance marker at the "content ready" point in a React component — i.e. after data has loaded and meaningful content is rendered, not on first paint/mount. Use when the user asks to add a PageReady marker, review an existing markPageReadyEnd placement, or ensure a marker fires at content-ready rather than shell-ready.
---
# PageReady Marker: Place at Content Ready

## Overview

`markPageReadyEnd()` is a performance marker from `@mc/performance/pageReady`. It should fire when the page's **primary content is visible and meaningful to the user** — not when the route shell or layout first mounts.

Two common mistakes:
- **First paint placement** — calling `markPageReadyEnd()` in a `useEffect(() => { ... }, [])`. This fires on the first render cycle, when the shell is painted but data has not yet loaded.
- **Too-deep placement** — calling it inside a deeply nested child component that may render before meaningful content is visible, or that may render multiple times.

The right location is wherever the **primary data for the page transitions from loading → loaded** and the content rows/cards/items are rendered for the first time.

## Clarifying Questions (Ask Before Proceeding)

Before placing or moving a marker, ask:

1. **What is the "content" for this page?** (e.g. contact rows, campaign cards, a form, a detail view)
2. **Where does that data load?** (e.g. Redux dispatch, React Query, `useEffect` fetch, server-rendered via `pageData`)
3. **Is there a loading state or skeleton?** If yes, the marker should fire when the skeleton disappears and real content is shown.
4. **Is the component a list/table (progressive load) or a detail view (single load)?**
   - List/table: fire after the first page of rows renders.
   - Detail view: fire after the primary record renders.
5. **Does the `Route` component support `manuallySetPageReady`?** If not, check with the XP team before bypassing auto-fire.

## Steps

### 1. Locate the current marker placement (if any)

```bash
grep -rn "markPageReadyEnd" web/js/src/Main/<ComponentDir>/
```

If none exists, identify the entry component for the route (usually `web/js/src/Main/<Feature>/index.js` or `index.tsx`).

### 2. Identify the data loading lifecycle

Read the component and answer:
- Is there a Redux action (e.g. `FETCH_*`) dispatched on mount?
- Is there a context/provider with an `isLoading` field?
- Is there a React Query `useQuery` hook?
- Is the data passed as props from `pageData` (server-rendered, already available on mount)?

**If data is already available on mount** (server-rendered `pageData`): placing the marker in `useEffect` on mount is acceptable — the content is already present. Document this explicitly.

**If data loads asynchronously after mount**: the marker must not fire until loading completes.

### 3. Choose the right placement pattern

#### Pattern A: Loading state in context/provider

When a context provides `isLoading` that transitions `true → false`:

```tsx
// Inside the child component that renders the actual content rows
import { markPageReadyEnd } from '@mc/performance/pageReady';
import { useMyContext } from './hooks/useMyContext';

const ContentList = () => {
  const { isLoading } = useMyContext();
  const attemptedInitialFetch = useRef(false);
  const hasMarkedPageReady = useRef(false);

  useEffect(() => {
    // ... dispatch initial fetch here
    attemptedInitialFetch.current = true;
  }, [...]);

  // Fire only after the initial fetch was dispatched AND loading has settled.
  // The attemptedInitialFetch guard prevents firing on the brief isLoading: false
  // state that exists before the first fetch is even dispatched.
  useEffect(() => {
    if (
      isOn(FLAGS.MY_FEATURE_CUSTOM_PAGE_READY) &&
      !isLoading &&
      attemptedInitialFetch.current &&
      !hasMarkedPageReady.current
    ) {
      hasMarkedPageReady.current = true;
      markPageReadyEnd();
    }
  }, [isLoading]);

  // ...render
};
```

**Two `useRef` guards are needed:**
- `hasMarkedPageReady` — prevents double-firing on refetch (isLoading can toggle multiple times)
- `attemptedInitialFetch` — prevents firing during the initial render before the first fetch is dispatched, when `isLoading` may briefly be `false`

#### Pattern B: React Query / data hook

```tsx
const { data, isLoading } = useMyDataQuery();
const hasMarkedReady = useRef(false);

useEffect(() => {
  if (!isLoading && data && !hasMarkedReady.current) {
    hasMarkedReady.current = true;
    markPageReadyEnd();
  }
}, [isLoading, data]);
```

#### Pattern C: Redux — fire after dispatch resolves

If a Redux `FETCH_*` action populates the store, the marker belongs in the component that reads the resulting data:

```tsx
const contacts = useSelector(selectContacts);
const isLoading = useSelector(selectIsLoading);
const hasMarkedReady = useRef(false);

useEffect(() => {
  if (!isLoading && contacts !== null && !hasMarkedReady.current) {
    hasMarkedReady.current = true;
    markPageReadyEnd();
  }
}, [isLoading, contacts]);
```

#### Pattern D: Server-rendered / pageData (data available on mount)

If all data is passed as props from the server-rendered `pageData` endpoint — no async load after mount:

```tsx
useEffect(() => {
  if (isOn(FLAGS.MY_FEATURE_CUSTOM_PAGE_READY)) {
    markPageReadyEnd();
  }
  // Data is server-rendered and available on mount — no guard needed
}, []);
```

Document clearly in a comment that this is intentional and why.

### 4. Place `manuallySetPageReady` on the Route

Whenever `markPageReadyEnd` is called manually, the `Route` must be told not to auto-fire. Set `manuallySetPageReady` conditionally on the flag:

```tsx
<Route
  title={routeTitle}
  manuallySetPageReady={isOn(FLAGS.MY_FEATURE_CUSTOM_PAGE_READY)}
>
```

This always belongs in the **top-level route component** (typically `index.js`/`index.tsx`) that renders the `<Route>` — even when `markPageReadyEnd` itself is called in a child component. The two are intentionally in different components.

### 5. Move the marker to the correct component

- **Do not place the marker in the top-level route shell** if data loads in a child.
- Place it in the **lowest component that knows when primary content is ready** — typically the list/table/card component, not the page wrapper.
- If the child is deeply nested and extracting the marker is complex, create a thin hook (e.g. `usePageReadyOnLoad`) and place it at the right level.

### 6. Verify placement is correct

Before committing, confirm:
- [ ] `markPageReadyEnd` is NOT called in a top-level `useEffect(() => {}, [])` that fires before data loads (unless Pattern D applies and data is server-rendered)
- [ ] `useRef` guard prevents double-firing on refetch
- [ ] `manuallySetPageReady` is set on `<Route>` in the top-level route component
- [ ] Flag wraps both the marker call and `manuallySetPageReady`

**Do not write tests for `markPageReadyEnd` marker placement.** The marker is a side-effect performance signal; its correctness is validated manually and via XP performance dashboards (see Step 7 below).

### 7. Manually validate the marker fires at the right time

After implementing, verify the event fires correctly in your local dev environment before pushing:

1. **Start the FE dev server** (`up --fe`)
2. **Log in** to the local environment
3. **Open browser DevTools** (Console tab)
4. **Set a localStorage flag** to enable RUM debug output:
   - Key: `o11y-rum-debug` → Value: `true`
   - This prints all RUM reporter events to the console in dev, E2E, and production
5. **Enable PageReady sending** — in `web/js/src/@mc/performance/pageReady.ts`, temporarily set `shouldSendToRUM` to `true`
   - **Revert this before committing** — it is a local-only debug change
6. **Navigate to your route** with the feature flag enabled for your account
7. **Filter the console** for `"net call raw:"`
8. **Look for `markMeasures`** in the logged objects — find an entry named `pageReady:{your-route}`
   - You may need to inspect several console entries since timing affects which batch it appears in
9. **Confirm timing** — the `pageReady` event should fire after your content data has loaded, not immediately on mount
10. **Optionally verify in Splunk** — after a minute or two, check the [PageReady Events Dev Dashboard](https://splunk.your-company.com/en-US/app/search/mailchimp_pageready_dev_events) to confirm events are reaching the RUM service

## Anti-Patterns to Reject

| Anti-pattern | Why it's wrong |
|---|---|
| `useEffect(() => { markPageReadyEnd(); }, [])` in shell component | Fires on first paint, before data loads |
| Calling without a `useRef` guard | May fire multiple times on refetch |
| Setting `manuallySetPageReady` without calling `markPageReadyEnd` | Page ready never fires — silent perf regression |
| Calling `markPageReadyEnd` outside a flag check | Can't roll back if the timing is wrong |
| Placing in a component that conditionally renders | Marker may never fire if the component is not mounted |

## Reference

- `@mc/performance/pageReady` — source of `markPageReadyEnd`
- `@mc/router` `Route` component — accepts `manuallySetPageReady` prop
- `#xp-team` — Slack channel for PageReady questions
