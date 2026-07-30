# A/B Test Significance Analysis
### Does Advertising Cause Real Conversions — Or Is It Random Chance?

**Tools:** BigQuery · SQL · Python (statsmodels, scipy, pandas) · Google Colab · Looker Studio  
**Data:** Marketing A/B Testing Dataset (Kaggle, faviovaz) — 588,101 users  
**Author:** Adnan — Marketing Data Analyst

---

## Project Summary

Most marketing teams see a conversion rate difference between a campaign and a control group and assume it's real. This project tests that assumption properly — using a full statistical validation pipeline, not just a surface-level comparison.

> *"Did our advertising actually cause more conversions, or could this difference be explained by random chance?"*

---

## Key Findings

| Finding | Detail |
|---|---|
| Sample Ratio Mismatch | **Passed** (p=0.9998) — traffic split verified stable, no tracking corruption |
| Ad group conversion rate | **2.5547%** vs 1.7854% for PSA control |
| Relative lift | **43.09%** |
| Statistical significance | **p < 0.0000000001** (Z = 7.37) — not due to random chance |
| Incremental conversions | **4,343** sales directly attributable to the ads |
| Power analysis | Sample size was **4.2x** the minimum required — reliably powered |
| Ad frequency confound | PSA group shows the same rising pattern with frequency — confirmed engagement-level selection bias, but ad group still outperforms by 5-6pp at matching frequency |

---

## Why This Project Is Different

Most portfolio A/B test projects stop at "conversion rate went up, p<0.05, done." This one goes further:

1. **Validates the experiment before trusting it** — Sample Ratio Mismatch (SRM) check, run in both SQL and Python, confirms the traffic split wasn't corrupted by a tracking bug before any conclusions are drawn.
2. **Controls for a real confound** — instead of assuming "more ads = more conversions," the analysis includes the PSA control group at every ad-frequency level, revealing that engagement level (not just ad exposure) drives part of the pattern — and quantifies the genuine ad effect underneath it.
3. **Reports the business number, not just the stats** — 4,343 incremental conversions is the number that gets a budget decision made, not a p-value alone.
4. **Confirms the test had enough data** — power analysis (using the statistically correct Cohen's h effect size, not a raw percentage) verifies the result isn't just significant but reliably so.

---

## Methodology

### Phase 1 — SQL (BigQuery)
- Sample Ratio Mismatch validation (aggregate + day-by-day stability check)
- Conversion rate by test group
- Ad frequency dose-response analysis, with PSA group as control
- Day-of-week breakdown, with PSA group as control

### Phase 2 — Python (Google Colab, live BigQuery connection)
- Authenticated connection to BigQuery — no manual data entry, queries run live
- Chi-square goodness-of-fit test (SRM validation)
- Two-proportion Z-test (core significance test)
- 95% confidence interval
- Incremental conversions calculation
- Power analysis using Cohen's h effect size
- Visualization: conversion rate comparison, ad frequency dose-response curve

### Phase 3 — Dashboard (Looker Studio)
- Headline KPIs: total users, total conversions, relative lift, significance verdict
- Ad vs PSA conversion rate chart
- Ad frequency dose-response chart (both groups)
- Day-of-week and hour-of-day breakdowns

---

## Results in Detail

### Core Significance Test

| Metric | Ad Group | PSA Group (Control) |
|---|---|---|
| Total Users | 564,577 | 23,524 |
| Conversions | 14,423 | 420 |
| Conversion Rate | **2.5547%** | 1.7854% |

- **Relative Lift:** 43.09%
- **Z-statistic:** 7.3701
- **P-value:** <0.0000000001
- **95% Confidence Interval:** [2.5135%, 2.5958%]
- **Incremental Conversions:** 4,343
- **Power Analysis:** Minimum required sample size (80% power) = 5,588 per group. Actual PSA group size = 23,524 (4.2x minimum) — adequately powered.

### Ad Frequency Analysis (Confound-Controlled)

| Frequency | Ad Conversion | PSA Conversion | Gap |
|---|---|---|---|
| 1-25 ads | 0.60% | 0.61% | ~0pp |
| 26-50 ads | 3.54% | 2.66% | +0.88pp |
| 51-100 ads | 11.63% | 5.77% | +5.86pp |
| 101-250 ads | **17.35%** | 11.23% | +6.13pp |
| 250+ ads | 15.97% | 15.75% | ~0pp |

**Both groups rise with frequency** — confirming engagement level is a real confound (highly active users see more impressions and convert more, regardless of ad exposure). **However, the ad group consistently outperforms PSA at matching frequency levels** (51-250 ads), by 5-6 percentage points, indicating a genuine incremental ad effect beyond baseline engagement. Both groups converge at 250+ ads, suggesting saturation.

### Day-of-Week Pattern

The ad group outperformed PSA on **every single day** of the week — confirming the overall lift isn't driven by one anomalous day. Monday (+1.07pp) and Tuesday (+1.60pp) showed the strongest incremental lift; Thursday showed the weakest (+0.14pp).

---

## Recommendation

The advertising campaign drove a statistically significant, substantial lift in conversions (43.09% relative lift, p<0.0000000001), generating an estimated 4,343 incremental sales. The test was adequately powered and the Sample Ratio Mismatch check confirmed experimental integrity. **Recommend continuing and scaling the campaign.**

- **Frequency capping:** Cap ad exposure around 250 impressions per user — returns plateau beyond this point in both groups.
- **Timing:** Consider weighting spend toward Monday and Tuesday, where incremental lift over baseline was strongest — validate over a longer test window before reallocating budget.

---

## Repository Structure

```
ab-test-significance-analysis/
│
├── ab_test_analysis.sql                          # 5 SQL queries with comments
├── AB_Test_Significance_Analysis.ipynb           # Full Colab notebook (code + markdown + charts)
├── AB_Test_Significance_Analysis_Writeup.docx    # One-page business writeup
├── AB_Test_Dashboard.pdf                          # Looker Studio dashboard export
└── README.md                                      # This file
```

---

## Limitations & Transparency

- Dataset covers a short time window (one week); day-of-week findings are directional, not conclusive, without a longer test period.
- Ad frequency analysis cannot fully separate causation from correlation — engagement level is a confirmed confound, partially addressed by the PSA control comparison but not eliminated entirely.
- Dataset is a public research dataset; company, product, and platform details are not disclosed.

---

## Skills Demonstrated

- **Experimental Design Validation** — Sample Ratio Mismatch (SRM) testing before trusting results
- **Statistical Testing** — Two-proportion Z-test, confidence intervals, Cohen's h power analysis
- **BigQuery SQL** — COUNTIF, window functions, CASE WHEN bucketing, multi-group comparison
- **Python** — statsmodels, scipy, pandas, live BigQuery API connection, matplotlib visualization
- **Analytical Rigor** — identifying and quantifying confounding variables rather than overstating causal claims

---

## Contact

**LinkedIn:** linkedin.com/in/adnan  
**Fiverr:** fiverr.com/adnan  
**Upwork:** upwork.com/adnan
