/*
===========================
Explore Breakdown of Reimbursements 
===========================

Script Purpose: 
	Explore and compare the breakdown of reimbursements (whether inpatient, outpatient, or carrier) 
	and compare breakdowns between super-utilizers (SU / top 10%) and the general population (GP / bottom 90%)
*/


USE desynpuf_practice;
GO

/*
===========
Breakdown of Reimbursements 
===========
*/

/*
There is a major shift in the breakdown of reimbursements between the SU and the GP.
For the general population, over half of the reimbursements came from the carriers so these beneficiaries likely relied mostly on their primary care physician.
However, for super-utilizers, over 75% of the reimbursements came from inpatient visits so they likely visited the hospital more often and stayed for longer.

In future projects, I will look more closely at the nature of these visits.
*/

SELECT
	is_super_utilizer,
	SUM(inpatient_medicare_reimb) AS total_inpatient_reimb,
	SUM(outpatient_medicare_reimb) AS total_outpatient_reimb,
	SUM(carrier_medicare_reimb) AS total_carrier_reimb,
	FORMAT(SUM(inpatient_medicare_reimb) * 100.0 / SUM(total_medicare_reimb), 'N2') + '%' AS inpatient_reimb_percent,
	FORMAT(SUM(outpatient_medicare_reimb) * 100.0 / SUM(total_medicare_reimb), 'N2') + '%' AS outpatient_reimb_percent,
	FORMAT(SUM(carrier_medicare_reimb) * 100.0 / SUM(total_medicare_reimb), 'N2') + '%' AS carrier_reimb_percent
FROM sample1.vw_beneficiaries_2008_su
GROUP BY is_super_utilizer;
GO
