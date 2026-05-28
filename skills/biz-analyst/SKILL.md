---
name: biz-analyst
description: Manage and execute tasks for biz-analyst.
  Use when defining KPIs for a product phase, calculating ROI on time or capital
  investment, measuring business impact of a feature, designing metrics dashboards,
  or forecasting growth over 3–12 months.
---
# Business Analyst

AI business analysis — KPIs, ROI, impact measurement, forecasting.

## Quick Start

```bash
/biz-analyst                                # Business health snapshot
/biz-analyst --feature=kpis                 # Define KPIs for current phase
/biz-analyst --feature=roi                  # ROI analysis
/biz-analyst --feature=impact               # Business impact of feature/change
/biz-analyst --feature=metrics              # Metrics dashboard design
/biz-analyst --feature=forecast             # Growth forecasting
/biz-analyst --feature=adoption             # Adoption scoring vs benchmarks
```

## Features

| Feature | What it does | Tokens |
|---------|-------------|--------|
| `kpis` | Define measurable KPIs for goals | 200-400 |
| `roi` | Calculate/project ROI | 300-500 |
| `impact` | Business impact of a change | 200-400 |
| `metrics` | Design tracking dashboard | 300-500 |
| `forecast` | 3-6-12 month growth model | 400-600 |
| `adoption` | Adoption rate vs market baseline | 200-300 |

## Three-Tier KPI Framework

Every metric mapped to:
```
Tier 1 (Actions):     npm downloads/week, GitHub stars, issues opened
Tier 2 (Efficiency):  Time to first use, docs page views, adoption rate
Tier 3 (Revenue):     Pro tier conversions, MRR, customer lifetime value
```

```bash
/biz-analyst --feature=kpis --phase=1-foundation
```

**Output:**
```
## Phase 1 KPIs (Foundation — Months 1-2)

### Tier 1: Activity Metrics
- npm weekly downloads: Target 500/week by end of month 2
- GitHub stars: Target 50+ stars
- Issues/PRs opened: Target 5+ community contributions

### Tier 2: Engagement Metrics
- Docs page views: Track via Cloudflare Analytics
- Time to first use: <5 min (measure via tutorial completion)

### Tier 3: Revenue Pipeline
- Email signups: Target 50 (pre-launch pipeline)
- Pro tier interest: Track "notify me" clicks

### Baseline: 0 (new launch)
### Success: Tier 1 targets hit by Month 2
```

## ROI Analysis

```bash
/biz-analyst --feature=roi --context="15 hrs/week for 12 months to reach $2K MRR"
```

**Output:**
```
## ROI Projection

### Investment
- Time: 15 hrs/week × 52 weeks = 780 hours
- Opportunity cost: ~$78,000 (at $100/hr market rate)

### Revenue Projection
Month 1-6:   $0 (build + launch)
Month 7:     $500 MRR (10 customers × $50)
Month 9:     $1,000 MRR (20 customers)
Month 12:    $2,000 MRR (40 customers)

Year 1 Revenue: ~$9,000

### Break-even
At $2K MRR: 4.5 years to match opportunity cost
At $5K MRR: 1.8 years — strong ROI

### Non-monetary ROI
- Portfolio + 500+ GitHub stars → recruiting leverage
- Skills built → market value increase
- Network built → compounding returns

### Recommendation
Strong play if $5K+ MRR is achievable (viable at 100 customers × $50)
```

## Memory Updates

After each session, updates:
- KPI baseline values (dated)
- ROI calculations recorded
- Milestone targets set
- Forecast assumptions

## Integration

```
/market-researcher --feature=opportunity  # Feed market data into ROI
/marketing-strategist --feature=gtm      # Turn metrics into launch plan
/po-guide --feature=roadmap              # Prioritize by business impact
```

---

**Token avg:** 200-500 per feature | **Cadence:** Quarterly + pre-release
