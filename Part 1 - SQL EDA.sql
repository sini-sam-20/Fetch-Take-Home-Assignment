-- Are there any data quality issues present?
-- Are there any fields that are challenging to understand?

--Missing values accross all tables. I have used sql to check for missing values in the tables.

-- Check for missing values in PRODUCTS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(BARCODE) AS non_null_barcode,
    COUNT(MANUFACTURER) AS non_null_manufacturer,
    COUNT(BRAND) AS non_null_brand,
    COUNT(CATEGORY_1) AS non_null_category_1

FROM products;

-- Check for missing values in TRANSACTIONS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(BARCODE) AS non_null_barcode,
    COUNT(FINAL_QUANTITY) AS non_null_quantity,
    COUNT(FINAL_SALE) AS non_null_sale

FROM transactions;

-- Check for missing values in USERS
SELECT 
    COUNT(*) AS total_rows,
    COUNT(BIRTH_DATE) AS non_null_birth_date,
    COUNT(STATE) AS non_null_state
    COUNT(GENDER) AS non_null_gender

FROM users;


-- Ambiguous values in FINAL_QUANTITY (TRANSACTIONS). It’s unclear whether this indicates returns, out-of-stock items, or another issue.
SELECT DISTINCT FINAL_QUANTITY
FROM transactions
WHERE FINAL_QUANTITY = 'zero';



-- 'MANUFACTURER' in PRODUCTS table has placeholder values like "PLACEHOLDER MANUFACTURER" and "NONE," which are ambiguous and make it difficult to analyze manufacturer-specific trends
SELECT DISTINCT MANUFACTURER
FROM products
WHERE MANUFACTURER IN ('PLACEHOLDER MANUFACTURER', 'NONE') OR MANUFACTURER IS NULL;
