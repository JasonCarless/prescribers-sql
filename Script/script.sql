--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
Select prescription.npi, total_claim_count
from prescription
join prescriber
using(npi)
where total_claim_count_ge65 is not null
order by total_claim_count desc;
-- NPI 1912011792 had the most claims with 4538
 
--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
Select total_claim_count, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
from prescription
join prescriber
using(npi)
where total_claim_count is not null
order by total_claim_count desc;
--David Coffey in Family Practice had the most claims filed with 4538

--2. a. Which specialty had the most total number of claims (totaled over all drugs)?
Select distinct prescriber.specialty_description, SUM(total_claim_count) as total_claims
from prescription
left join prescriber
using(npi)
group by specialty_description
order by total_claims desc;
--Family practice has the most number of claims wtih 9,752,347

--b. Which specialty had the most total number of claims for opioids?
Select distinct prescriber.specialty_description, SUM(total_claim_count) as total_claims
from prescription
left join prescriber
using(npi)
inner join drug
on drug.drug_name = prescription.drug_name
where drug.opioid_drug_flag = 'Y'
group by specialty_description
order by total_claims desc;
--nurse practitioner had the most with 900,845 
    

--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3. a. Which drug (generic_name) had the highest total drug cost?
select generic_name, total_drug_cost
from drug
inner join prescription
using(drug_name)
group by generic_name, total_drug_cost
order by total_drug_cost desc;
-- "PIRFENIDONE" with a cost of $2,829,174.3

--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
select generic_name, (total_drug_cost/total_day_supply) as cost_per_day
from drug
join prescription
using(drug_name)
group by generic_name, cost_per_day
order by cost_per_day desc;
--"IMMUN GLOB G(IGG)/GLY/IGA OV50" has a cost per day of $7,141.1066666666666667

--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
Select drug_name,
case when opioid_drug_flag = 'Y' then 'Opiod'
     when antibiotic_drug_flag = 'Y' then 'Antibiotic'
     else 'neither' end as drug_type
     from drug;
--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
Select sum(total_drug_cost) as MONEY,
case when opioid_drug_flag = 'Y' then 'Opiod'
     when antibiotic_drug_flag = 'Y' then 'Antibiotic'
     else 'neither' end as drug_type
     from drug
     inner join prescription 
     on prescription.drug_name = drug.drug_name
     group by drug_type
     order by drug_type desc;
-- More was spent on opioids. $105,080,626.37 on opiods vs $38,435,121.26 on antibiotics

--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
select *
from cbsa
inner join fips_county
on cbsa.fipscounty = fips_county.fipscounty 
where state = 'TN';
--there are 42 cbas in Tennessee

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
select cbsaname, SUM(population) as combined_pop
from population
left join cbsa
on population.fipscounty = cbsa.fipscounty
group by cbsaname
order by combined_pop desc;
-- "Nashville-Davidson--Murfreesboro--Franklin, TN" is the largest with a population of 1830410
-- "Morristown, TN" is the smallest with 116352

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
Select f.county, p.population
from population as p
left join fips_county as f
on p.fipscounty = f.fipscounty
left join cbsa as c
on p.fipscounty = c.fipscounty
where c.fipscounty is null
order by p.population desc;
--sevier has the highest population with 95523

--6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
select drug_name, total_claim_count
from prescription
where total_claim_count > 3000;

--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
select drug_name, total_claim_count,
 (select opioid_drug_flag
  from drug
  where prescription.drug_name = drug.drug_name) as opioid
from prescription
where total_claim_count > 3000;

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
select drug.drug_name, total_claim_count, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
from prescription
inner join drug
on prescription.drug_name = drug.drug_name
inner join prescriber
on prescription.npi = prescriber.npi
where total_claim_count > 3000;

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
select npi, drug_name
from prescriber
cross join drug
where specialty_description = 'Pain Management'
and nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y';

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.