--Creating table
CREATE TABLE loan_project (
    end_of_period TIMESTAMP,
    loan_number VARCHAR(255),
    region VARCHAR(255),
    country_code VARCHAR(10),
    country VARCHAR(255),
    borrower VARCHAR(255),
    guarantor_country_code VARCHAR(10),
    guarantor VARCHAR(255),
    loan_type VARCHAR(255),
    loan_status VARCHAR(255),
    interest_rate DECIMAL(10, 4),
    currency_of_commitment VARCHAR(50),
    project_id VARCHAR(50),
    project_name VARCHAR(255),
    original_principal_amount DECIMAL(18, 2),
    cancelled_amount DECIMAL(18, 2),
    undisbursed_amount DECIMAL(18, 2),
    disbursed_amount DECIMAL(18, 2),
    repaid_to_ibrd DECIMAL(18, 2),
    due_to_ibrd DECIMAL(18, 2),
    exchange_adjustment DECIMAL(18, 2),
    borrower_s_obligation DECIMAL(18, 2),
    sold_3rd_party DECIMAL(18, 2),
    repaid_3rd_party DECIMAL(18, 2),
    due_3rd_party DECIMAL(18, 2),
    loans_held DECIMAL(18, 2),
    first_repayment_date TIMESTAMP,
    last_repayment_date TIMESTAMP,
	agreement_signing_date TIMESTAMP,
    board_approval_date TIMESTAMP,
	effective_date_most_recent TIMESTAMP,
	closed_date_most_recent TIMESTAMP,
	last_disbursement_date TIMESTAMP
);

--1:How many loans were approved this year?
SELECT COUNT(*) AS loans_this_year
FROM loan_project
WHERE EXTRACT(YEAR FROM agreement_signing_date) = 2024;
--58 loans signed this year.

--2:What is the top 10 loan amount by country?
SELECT country, SUM(original_principal_amount) AS sum_opm
FROM loan_project
GROUP BY country
ORDER BY sum_opm DESC
LIMIT 10;

--3:Which country has the highest number of loans currently?
SELECT country, COUNT(loan_status)
FROM loan_project
WHERE loan_status = 'Repaying'
GROUP BY country
LIMIT 1;
--Indonesia has 71 current loan.

--4:What is the average loan amount by country or region?
SELECT 
    country, 
    region, 
    ROUND(AVG(original_principal_amount), 0) AS avg_original_principal_amount
FROM loan_project
WHERE original_principal_amount IS NOT NULL
GROUP BY country, region
ORDER BY avg_original_principal_amount DESC
LIMIT 10;

--5:How many loans are currently in each status (e.g., repaid, due, held)?
SELECT loan_status, COUNT(loan_status) AS loan_total
FROM loan_project
GROUP BY loan_status
ORDER BY loan_total DESC;

--6:What is the distribution of loan types across different regions?
WITH LoanCounts AS (
    SELECT
        region,
        loan_status,
        COUNT(loan_status) AS loan_count
    FROM
        loan_project
    GROUP BY
        region,
        loan_status
),
TotalCounts AS (
    SELECT
        region,
        SUM(loan_count) AS Total_Loans
    FROM
        LoanCounts
    GROUP BY
        region
)
SELECT
    lc.region,
    lc.loan_status,
    lc.loan_count,
    ROUND((lc.Loan_Count * 100.0 / tc.Total_Loans), 2) AS Percentage
FROM
    LoanCounts lc
JOIN
    TotalCounts tc
ON
    lc.region = tc.region
ORDER BY
    lc.region, lc.loan_status;

--7:Which borrower has the highest total loan amounts?
SELECT country, MAX(original_principal_amount) AS max_opm
FROM loan_project
GROUP BY country
LIMIT 1;
--Bangladesh has the highest single loan amount.

--8:What is the average time between agreement signing and the first repayment date?
SELECT ROUND(
    AVG(EXTRACT(EPOCH FROM (first_repayment_date - agreement_signing_date)) / 86400.0)
) AS avg_days
FROM loan_project
WHERE agreement_signing_date IS NOT NULL
    AND first_repayment_date IS NOT NULL;
--The average time between agreement and first repayment is 2084 days.   

--9:How many loans have been repaid to third parties by country?
SELECT country, COUNT(loan_status) AS loan_count
FROM loan_project
WHERE loan_status = 'Fully Repaid'
AND repaid_3rd_party IS NOT NULL
GROUP BY country
ORDER BY loan_count DESC;

--10:What is the average loan duration by loan type?
SELECT loan_status, ROUND(
    AVG(EXTRACT(EPOCH FROM (last_repayment_date - first_repayment_date)) / 86400.0)
) AS avg_days
FROM loan_project
WHERE last_repayment_date IS NOT NULL
    AND first_repayment_date IS NOT NULL
GROUP BY loan_status
ORDER BY avg_days;

--11:How many loans have been closed within the last 10 years?(today is 07/22/2024)
SELECT COUNT(*) AS total_closed_loans
FROM loan_project
WHERE last_repayment_date >= '2014-07-22';
--3398 loans have been closed in the last 10 years

--12:What is the total amount of loans due to third parties by region?
SELECT region, COUNT(due_3rd_party) AS sum_3rd_party
FROM loan_project
WHERE due_3rd_party IS NOT NULL
GROUP BY region
ORDER BY sum_3rd_party DESC;

--13:How many loans were signed between 2001 and 2005
SELECT COUNT(agreement_signing_date) AS loans_signed
FROM loan_project 
WHERE agreement_signing_date BETWEEN '2001-01-01' AND '2005-12-31';
--516 loans were signed

--14:What is the average loan amount for each borrower?
SELECT ROUND(AVG(original_principal_amount),0) AS avg_loan_amount , borrower
FROM loan_project
WHERE borrower IS NOT NULL
GROUP BY borrower
ORDER BY avg_loan_amount DESC;

--15:Which loans have the earliest and latest last disbursement dates?
(
    SELECT loan_number, last_disbursement_date
    FROM loan_project
    WHERE last_disbursement_date IS NOT NULL
    ORDER BY last_disbursement_date ASC
    LIMIT 1
)
UNION ALL
(
    SELECT loan_number, last_disbursement_date
    FROM loan_project
    WHERE last_disbursement_date IS NOT NULL
    ORDER BY last_disbursement_date DESC
    LIMIT 1
);

