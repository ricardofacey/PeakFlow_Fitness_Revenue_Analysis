# PeakFlow Fitness — Revenue Analysis (2023–2024)

**AOV Decline, Customer Churn, and Growth Opportunities**

---

## Problem Statement

PeakFlow Fitness experienced near-zero revenue growth year-over-year (-0.11%) despite 78% of customers making repeat purchases.  
    
This analysis identifies the root causes of stagnation and quantifies the revenue impact of targeted growth initiatives.

---

## Tools & Methods

| Tool | Purpose |
|------|--------|
| SQL | Data extraction and transformation |
| Excel | Exploratory analysis and hypothesis validation |
| Tableau | Data visualization and dashboard development |

---

## Approach

- Segmented customers into repeat vs. one-time buyers  
- Analyzed AOV trends by segment  
- Decomposed AOV into basket size and average item price  
- Evaluated retention and acquisition dynamics  
- Identified product-level growth opportunities  

---

## Key Findings

### 1. Revenue is Highly Dependent on Repeat Customers
- 78% of customers (2,841) made more than one order  
- This segment drove **92% of total revenue** ($4.4M of $4.8M)  
- Any behavioral shift among repeat customers has an outsized impact on overall revenue  

---

### 2. Declining Item Prices Among Repeat Customers Canceled AOV Growth
- Basket size remained stable across both segments (~5.0 items/order)  
- Repeat customers saw a **$0.74 decrease** in average item price (2023 → 2024)  
- One-time customers saw a **$13.58 increase** in AOV over the same period  
- Because repeat customers dominate revenue, this decline offset AOV gains from one-time customers, keeping total revenue flat  

---

### 3. Customer Churn Offset New Acquisition
- PeakFlow started 2023 with 2,853 customers  
- ~28% (813) churned and did not order in 2024  
- 811 new customers were acquired in 2024  
- **Net customer change: -2 YoY** — acquisition and churn nearly perfectly canceled out  

---

## Recommendations

### 1. Cross-Selling and Product Bundling
- Bundle high-frequency products with higher-margin complementary items  
- Implement a "frequently bought together" feature to increase basket size  

### 2. Leverage High-Growth Products for Acquisition
- Prioritize the top 10 fastest-growing products (by units sold) in marketing  
- Use margin flexibility to support promotions and conversion among new customers  

### 3. Win-Back Campaigns to Reduce Churn
- Build an automated post-purchase lifecycle funnel  
- Use personalized offers and purchase-based targeting to re-engage at-risk customers  

---

## Estimated Business Impact

| Initiative | Estimated Incremental Revenue | Growth Type |
|-----------|-----------------------------|------------|
| AOV increase via bundling (+0.5 items/order) | $200K–$250K (~8–10%) | Near-term lever |
| Net customer growth (+120 customers/year) | ~$100K (~4%) | Long-term growth driver |

**Total Opportunity**  
~10% revenue growth from AOV expansion alone, with additional upside from customer growth initiatives  

*Estimates based on current AOV (~$480), order volume (~5,000/year), and average annual revenue per customer (~$842). Impacts are not strictly additive.*

---

## Key Takeaway

Revenue stagnation was driven by two offsetting forces:
- Declining spend among repeat customers (lower item prices)  
- Customer churn offsetting new acquisition  

**AOV expansion is the primary near-term growth lever**, offering ~10% revenue upside through increased basket size.  

However, **long-term growth depends on improving customer acquisition and retention**, as the business is currently highly reliant on repeat customers for revenue.

---

## Dashboard

Built a Tableau dashboard to track AOV by segment, basket size, item pricing, retention, and product performance in a single view.

---

## Repository Structure

    peakflow-revenue-analysis/
    ├── data/               # Raw and transformed data (anonymized)
    ├── sql/                # Extraction and transformation queries
    ├── dashboard/          # Tableau jpeg
    └── README.md

---

## Author

**Ricardo Facey**  
Data Analyst | SQL · Excel · Tableau
