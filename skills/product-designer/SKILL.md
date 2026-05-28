---
name: product-designer
description: Manage and execute tasks for product-designer.
  Use when designing a UI component spec, auditing for WCAG 2.1 AA accessibility
  violations (missing ARIA, contrast, keyboard nav), reviewing design system consistency,
  analyzing user flows, or evaluating design token architecture.
---
# Product Designer

AI product designer — UX/UI review, accessibility, component design, design system consistency.

## Quick Start

```bash
/product-designer                           # Design health check
/product-designer --feature=component       # Component design spec
/product-designer --feature=accessibility   # A11y / WCAG audit
/product-designer --feature=consistency     # Design system consistency check
/product-designer --feature=flow            # User flow analysis
/product-designer --feature=tokens          # Token system review
/product-designer --feature=hierarchy       # Visual hierarchy review
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `component` | Design spec for new component | 300-500 |
| `accessibility` | WCAG 2.1 AA full audit | 300-500 |
| `consistency` | Cross-component consistency check | 300-400 |
| `flow` | User journey + friction analysis | 300-500 |
| `tokens` | Design token architecture review | 200-400 |
| `hierarchy` | Visual hierarchy + readability | 200-300 |

## Component Design Spec

```bash
/product-designer --feature=component --context="Toast notification component"
```

**Output:**
```
## Component Spec: Toast Notification

### Variants
- Success (green), Error (red), Warning (yellow), Info (blue)
- Positions: top-right (default), bottom-center, top-center

### Anatomy
- Icon (left) → Message (center) → Close button (right)
- Optional: Action button (e.g., "Undo")

### States
- Enter: slide-in from right (respect prefers-reduced-motion)
- Idle: visible for 4s default
- Exit: fade-out
- Stacked: max 3 visible, queue rest

### Accessibility
- role="alert" for error/warning, role="status" for info/success
- aria-live="polite" or "assertive" based on type
- Close button: aria-label="Dismiss notification"
- Focus: return to trigger on close

### Tokens
--av-toast-bg: var(--av-color-surface-raised)
--av-toast-border: var(--av-color-border)
--av-toast-shadow: var(--av-shadow-lg)
--av-toast-radius: var(--av-radius-md)

### CSS Class
.av-toast, .av-toast-success, .av-toast-error, .av-toast-warning
```

## Accessibility Audit

```bash
/product-designer --feature=accessibility --file=src/components.js
```

Checks:
- ARIA roles, labels, descriptions
- Keyboard navigation (tab order, focus traps, escape handling)
- Color contrast (4.5:1 normal, 3:1 large text)
- Screen reader announcements
- Motion sensitivity (prefers-reduced-motion)
- Touch targets (44×44px minimum)

Output: Prioritized issue list with code fixes

## Design Consistency

```bash
/product-designer --feature=consistency
```

Detects:
- Hardcoded colors instead of token references
- Inconsistent spacing (magic numbers not using token scale)
- Mismatched border-radius across components
- Icon size inconsistencies
- Typography scale violations

## Memory Updates

After each session, updates:
- Component design decisions
- A11y issues found + fixed
- Token system evolution
- UX patterns established

## Integration

```
/dev-assistant --feature=patterns      # Align design with code patterns
/qa-automation --feature=accessibility # Automate a11y testing
/orchestrate --phase=component-build   # Full component creation workflow
```

---

**Token avg:** 250-500 per feature | **Standards:** WCAG 2.1 AA, WAI-ARIA
