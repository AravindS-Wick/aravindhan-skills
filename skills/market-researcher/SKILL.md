---
name: market-researcher
description: >
  Use when analyzing competitors, researching technology or market trends, validating
  a feature idea against user demand, identifying unserved market gaps, or defining
  product positioning before building customer-facing features.
---

# Market Researcher

AI market intelligence — competitors, trends, user insights, opportunity analysis.

## Quick Start

```bash
/market-researcher                          # Market snapshot for current project
/market-researcher --feature=competitors    # Competitor analysis
/market-researcher --feature=trends         # Technology + market trends
/market-researcher --feature=users          # User research synthesis
/market-researcher --feature=opportunity    # Gap/opportunity mapping
/market-researcher --feature=positioning    # Market positioning analysis
/market-researcher --feature=validate       # Validate a feature idea
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `competitors` | Competitor feature matrix + gaps | 400-600 |
| `trends` | Tech/market trends relevant to project | 300-500 |
| `users` | User persona + pain point synthesis | 300-500 |
| `opportunity` | Unserved needs + market gaps | 400-600 |
| `positioning` | Unique positioning vs competitors | 300-400 |
| `validate` | Validate feature idea against market | 200-400 |

## Competitor Analysis

```bash
/market-researcher --feature=competitors --context="CSS design system npm package"
```

**Output:**
```
## Competitor Matrix: CSS Design Systems

| Package | Stars | Weekly DL | Price | Gap |
|---------|-------|-----------|-------|-----|
| Tailwind | 82k | 12M | Free | Heavy, purge needed |
| Bootstrap | 170k | 8M | Free | Old patterns, large |
| Shoelace | 12k | 40k | Free | Web components only |
| **@aravi1008/ui** | — | — | — | Opportunity below |

### Gaps We Can Own
1. Zero-config SSR-safe (Tailwind requires purge)
2. Semantic theme tokens (not utility classes)
3. Design system + JS behavior together (Bootstrap splits them)

### Recommendation
Position as: "Design system for developers who want semantic CSS + behavior, not utility class soup"
```

## Technology Trends

```bash
/market-researcher --feature=trends --context="frontend tooling 2025"
```

Returns:
- Relevant trends affecting your project
- Technologies rising vs declining
- What to adopt now vs watch vs skip
- Community momentum indicators

## Feature Validation

```bash
/market-researcher --feature=validate --context="Add CSS-in-JS output to design system"
```

Checks:
- Do competitors offer this?
- Is there user demand (signals)?
- Does it align with positioning?
- Build vs ignore recommendation

## Memory Updates

After each session, updates:
- Competitor landscape snapshot (dated)
- Trends identified
- Strategic opportunities logged
- Positioning decisions

## Integration

```
/biz-analyst --feature=roi          # Quantify opportunity
/marketing-strategist --feature=gtm # Turn insights into GTM
/po-guide --feature=roadmap         # Feed into product roadmap
```

---

**Token avg:** 300-600 per feature | **Cadence:** Monthly or pre-feature
