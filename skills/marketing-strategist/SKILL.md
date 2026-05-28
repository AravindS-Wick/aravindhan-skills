---
name: marketing-strategist
description: >
  Use when planning a product launch, building go-to-market strategy, writing positioning
  statements, creating launch week checklists, drafting email drip sequences, or building
  a content calendar for developer-focused products.
---

# Marketing Strategist

AI marketing lead — GTM strategy, messaging, positioning, launch campaigns.

## Quick Start

```bash
/marketing-strategist                       # Marketing snapshot for current phase
/marketing-strategist --feature=gtm         # Go-to-market strategy
/marketing-strategist --feature=messaging   # Value proposition + messaging
/marketing-strategist --feature=positioning # Market positioning
/marketing-strategist --feature=launch      # Launch campaign plan
/marketing-strategist --feature=content     # Content strategy
/marketing-strategist --feature=email       # Email sequences
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `gtm` | Full go-to-market plan | 500-700 |
| `messaging` | Value prop, taglines, copy | 300-500 |
| `positioning` | Differentiation statement | 200-400 |
| `launch` | Launch week checklist + timeline | 400-600 |
| `content` | Blog/docs/social content strategy | 300-500 |
| `email` | Drip sequence + nurture emails | 400-600 |

## GTM Strategy

```bash
/marketing-strategist --feature=gtm --context="@aravi1008/ui v1.5 launch"
```

**Output:**
```
## GTM: @aravi1008/ui v1.5

### Target Audience (ICP)
- Solo developers / indie hackers building web apps
- Frontend devs tired of configuring Tailwind
- Teams wanting design system without Figma overhead

### Positioning Statement
"@aravi1008/ui is the only CSS design system that works zero-config, 
ships behavior + styles together, and respects your tokens."

### Channels (Priority Order)
1. Dev.to / Hashnode — Tutorial posts (organic, high dev intent)
2. Twitter/X — Demo GIFs, release threads (viral potential)
3. GitHub README — Discovery via npm search
4. Product Hunt — Launch day spike

### Launch Week Timeline
Day -7: Teaser post ("building something...")
Day -3: Dev.to tutorial published
Day -1: Show HN draft ready
Day 0:  Product Hunt launch + Twitter thread
Day +2: Follow-up: "what we learned" post

### Success Metrics
- 500 npm installs week 1
- 100 GitHub stars
- 50 new email subscribers
```

## Messaging Framework

```bash
/marketing-strategist --feature=messaging
```

**Output:**
```
## Messaging Framework

### Primary Value Prop (1 line)
"Design system that just works — no config, no purge, no tradeoffs."

### Tagline Options
1. "Ship faster. Style smarter." 
2. "One install. Full design system."
3. "CSS that thinks like a developer."

### Pain Points We Address
- "Tailwind requires too much config/purge setup"
- "Bootstrap looks dated and is hard to customize"
- "Building a design system from scratch takes months"

### Proof Points
- Zero-config SSR: works with Next.js, Nuxt, SvelteKit out of box
- 25 components included
- 6 themes with one line change
- <10KB gzipped
```

## Launch Campaign

```bash
/marketing-strategist --feature=launch --date=2026-05-01
```

Returns:
- Week-by-week pre-launch content calendar
- Launch day checklist (Product Hunt, Hacker News, Reddit)
- Post-launch amplification plan
- Template posts/tweets ready to publish

## Email Sequences

```bash
/marketing-strategist --feature=email --audience=developer-signups
```

Generates drip sequence:
- Email 1: Welcome + quick start guide
- Email 2: Feature highlight (3 days)
- Email 3: Case study / how to use (7 days)
- Email 4: Pro tier intro (14 days)

## Memory Updates

After each session, updates:
- Positioning decisions (don't repeat analysis)
- Content calendar items
- Channel performance notes
- Campaign results

## Integration

```
/market-researcher --feature=competitors   # Inform positioning
/biz-analyst --feature=roi                 # Validate investment in marketing
/orchestrate --phase=pre-release           # Full launch orchestration
```

---

**Token avg:** 300-600 per feature | **Cadence:** Pre-release + quarterly
