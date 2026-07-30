-- ============================================================
-- A/B TEST SIGNIFICANCE ANALYSIS
-- Does Advertising Cause Real Conversions — Or Is It Random Chance?
-- Author: Adnan
-- Tools: BigQuery SQL + Python (statsmodels, scipy)
-- Data Source: Marketing A/B Testing dataset (Kaggle, faviovaz)
-- Description: A/B test comparing ad-exposed users against a PSA
--   control group. Includes Sample Ratio Mismatch validation,
--   conversion rate analysis, ad frequency dose-response analysis
--   with confound control, and day-of-week breakdown.
-- ============================================================


-- ------------------------------------------------------------
-- Query 0: Sample Ratio Mismatch (SRM) Check
-- Purpose: Verify the traffic split between test groups is
--          stable and not corrupted by a tracking bug, BEFORE
--          trusting any downstream significance test.
-- Result: 96% ad / 4% psa — confirmed intentional holdout design,
--          not a 50/50 split (standard practice for large-scale
--          ad experiments where withholding ads from half the
--          audience would be commercially impractical).
-- ------------------------------------------------------------
SELECT
  test_group,
  COUNT(*) AS users,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS actual_split_ratio
FROM `paid-compaigns-porject.ab_testing_analysis.marketing_ab_test`
GROUP BY test_group;


-- ------------------------------------------------------------
-- Query 0b: SRM Stability Check — Day by Day
-- Purpose: Confirm the split ratio is stable across every day
--          of the week (not just in aggregate) — rules out a
--          day-specific tracking failure.
-- Result: Ratio stayed within 95.3%-96.5% every single day —
--          confirmed stable, no corruption detected.
-- ------------------------------------------------------------
SELECT
  most_ads_day,
  test_group,
  COUNT(*) AS users,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY most_ads_day), 4) AS daily_split_ratio
FROM `paid-compaigns-porject.ab_testing_analysis.marketing_ab_test`
GROUP BY most_ads_day, test_group
ORDER BY most_ads_day, test_group;


-- ------------------------------------------------------------
-- Query 1: Conversion Rate by Test Group
-- Purpose: Core comparison — headline conversion rate for the
--          ad-exposed group vs the PSA control group. These
--          numbers feed directly into the Python significance test.
-- Result: Ad group 2.5547% vs PSA group 1.7854% — a 43.09%
--          relative lift.
-- ------------------------------------------------------------
SELECT
  test_group,
  COUNT(*) AS total_users,
  COUNTIF(converted = TRUE) AS conversions,
  ROUND(COUNTIF(converted = TRUE) * 100.0 / COUNT(*), 4) AS conversion_rate_pct
FROM `paid-compaigns-porject.ab_testing_analysis.marketing_ab_test`
GROUP BY test_group;


-- ------------------------------------------------------------
-- Query 2: Ad Frequency Analysis (Dose-Response, BOTH groups)
-- Purpose: Test whether conversion rate rises, plateaus, or
--          declines as ad exposure frequency increases. Includes
--          the PSA group as a control to isolate true ad effect
--          from general user-engagement selection bias.
-- Result: Ad group conversion rises sharply up to 101-250 ads
--          (17.35%) then declines slightly at 250+ (15.97%).
--          PSA group shows the SAME rising pattern — confirming
--          engagement-level selection bias is a real confound.
--          However, ad group still outperforms PSA by 5-6pp at
--          matching frequency levels (51-250 ads), suggesting a
--          genuine incremental ad effect beyond baseline engagement.
--          Both groups converge at 250+ ads, suggesting saturation.
-- ------------------------------------------------------------
SELECT
  test_group,
  CASE
    WHEN total_ads BETWEEN 1 AND 25 THEN '1) 1-25 ads'
    WHEN total_ads BETWEEN 26 AND 50 THEN '2) 26-50 ads'
    WHEN total_ads BETWEEN 51 AND 100 THEN '3) 51-100 ads'
    WHEN total_ads BETWEEN 101 AND 250 THEN '4) 101-250 ads'
    WHEN total_ads > 250 THEN '5) 250+ ads'
  END AS ad_frequency_bucket,
  COUNT(*) AS users,
  COUNTIF(converted = TRUE) AS conversions,
  ROUND(COUNTIF(converted = TRUE) * 100.0 / COUNT(*), 4) AS conversion_rate_pct
FROM `paid-compaigns-porject.ab_testing_analysis.marketing_ab_test`
GROUP BY test_group, ad_frequency_bucket
ORDER BY ad_frequency_bucket, test_group;


-- ------------------------------------------------------------
-- Query 3: Conversion Rate by Day of Week (BOTH groups)
-- Purpose: Check whether ad effectiveness is consistent across
--          the week, or concentrated on specific days. PSA
--          included as control to separate "ad timing effect"
--          from "people just browse/buy more on certain days."
-- Result: Ad group outperforms PSA on every single day (lift is
--          consistent, not a one-day artifact). Monday (+1.07pp)
--          and Tuesday (+1.60pp) show the strongest incremental
--          lift; Thursday shows the weakest (+0.14pp).
-- ------------------------------------------------------------
SELECT
  test_group,
  most_ads_day,
  COUNT(*) AS users,
  COUNTIF(converted = TRUE) AS conversions,
  ROUND(COUNTIF(converted = TRUE) * 100.0 / COUNT(*), 4) AS conversion_rate_pct
FROM `paid-compaigns-porject.ab_testing_analysis.marketing_ab_test`
GROUP BY test_group, most_ads_day
ORDER BY most_ads_day, test_group;
