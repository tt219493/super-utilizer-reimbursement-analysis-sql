# SQL: Analysis of Super-Utilizers in Medicare Using Reimbursements
Quantifying share of healthcare utilization by super-utilizers using reimbursements and finding distinguishing characteristics of this population.

Analysis done using T-SQL in SQL Server and synthetic Medicare dataset.

---
## Outline
**Focus:** Demonstrating the issue of super-utilizers and identifying interventions for this issue.

**Approach:** Using a synthetic Medicare dataset, quantify how the share of healthcare utilization is concentrated using among super-utilizers using total Medicare reimbursements and find characteristics that distinguish them from the general population to determine possible interventions.

**Languages & Software:** T-SQL, SQL Server (2022)  
**Dataset:** CMS Medicare Claims Synthetic Public Use Files:
[Dataset](https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-claims-synthetic-public-use-files/cms-2008-2010-data-entrepreneurs-synthetic-public-use-file-de-synpuf/de10-sample-1), [Codebook](https://www.cms.gov/files/document/de-10-codebook.pdf-0)

**Steps:**
- Select cohort & explore distribution of Medicare reimbursements.
- Calculate percentiles for reimbursements & label beneficiaries as super-utilizers if in the 90th percentile or higher.
- Calculate share of utilization by super-utilizers & calculate Gini coefficient to demonstrate the unequal distribution.
- Calculate breakdown of demographics and other characteristics among super-utilizers and the general population.
- Compare prevalence of characteristics between super-utilizers and general population & calculate prevalence ratios with 95% confidence intervals for statistical significance.

**Results:** 
- The top 10% of utilizers account for 63.1% of total healthcare utilization.
- The top 5% of utilizers account for 45.6% of total healthcare utilization.
- The Gini coefficient is 0.757.
- All chronic conditions explored are more prevalent in the super-utilizer population with statistical significance.
- Highest prevalence is Ischemic Heart Disease at 91.96% of the super-utilizer population.
- Highest increase in prevalence is Stroke/Transient Ischemic Attack at 5.671 times more prevalent in the super-utilizer population over the general population.
- There is an increase in spending as number of conditions increase and the prevalence ratio increases as number of conditions increase as well.

Results demonstrate that super-utilizers are an important issue to be addressed to reduce healthcare spending, especially since they are a small part of the entire Medicare population.  
