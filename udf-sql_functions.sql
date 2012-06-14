------ 
-- Returns if argument is from type INT. 
-- @a      - int candidate
-- @return - true iff argument is INT
-- The range of INTEGER is -2^63+1 to 2^63-1.
------
CREATE OR REPLACE FUNCTION is_int(a varchar(65000))
RETURN BOOLEAN
  AS BEGIN
    RETURN 
        REGEXP_LIKE(TRIM(a),'^\d{1,19}$') 
          AND 
        ABS(a::NUMERIC) < 9223372036854775808;     -- check range
  END;


------ 
-- Extracts month name from month NUMBER 
-- @month  - moth number candidate
-- @return - month name iff month number is valid otherwise null
------
CREATE OR REPLACE FUNCTION month_name(month INT)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN (CASE
      WHEN (month = 1)  THEN 'January'
      WHEN (month = 2)  THEN 'February'
      WHEN (month = 3)  THEN 'March'
      WHEN (month = 4)  THEN 'April'
      WHEN (month = 5)  THEN 'May'
      WHEN (month = 6)  THEN 'June'
      WHEN (month = 7)  THEN 'July'
      WHEN (month = 8)  THEN 'August'
      WHEN (month = 9)  THEN 'September'
      WHEN (month = 10) THEN 'October'
      WHEN (month = 11) THEN 'November'
      WHEN (month = 12) THEN 'December'
    END);
  END;

------ 
-- Extracts month name from DATE.
-- @dt     - date candidate
-- @return - month name iff month number is valid otherwise null
------
CREATE OR REPLACE FUNCTION month_name(dt DATE)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN month_name(MONTH(dt));
  END;


------ 
-- Extracts month name from TIMESTAMP.
-- @ts     - timestamp candidate
-- @return - month name iff month number is valid otherwise null
------
CREATE OR REPLACE FUNCTION month_name(ts TIMESTAMP)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN month_name(MONTH(ts));
  END;