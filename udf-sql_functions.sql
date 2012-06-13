------ 
-- Returns if argument is from type INT. 
-- @a      - int candidate
-- @return - true iff argument is INT
-- The range of INTEGER is -2^63+1 to 2^63-1.
------
CREATE OR REPLACE FUNCTION is_int(a varchar(65000))
RETURN BOOLEAN
  AS BEGIN
    RETURN (
        REGEXP_LIKE(a,'^\d{1,19}$') 
          OR 
        REGEXP_LIKE(a,'^[1-9](\d+)?\.\d+e[-+]\d+')        -- validate sientific notation
          OR
        REGEXP_LIKE(a,'','')                              -- TODO: validate hex notation
    ) AND
        ABS(a::numeric) <= 9223372036854775807);          -- check range
  END;


------ 
-- Converts month number to name 
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
-- Extracts month name from date.
-- @d      - date candidate
-- @return - month name iff month number is valid otherwise null
------
CREATE OR REPLACE FUNCTION month_name(d DATE)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN (CASE
      WHEN (month(d) =  1) THEN 'January'
      WHEN (month(d) =  2) THEN 'February'
      WHEN (month(d) =  3) THEN 'March'
      WHEN (month(d) =  4) THEN 'April'
      WHEN (month(d) =  5) THEN 'May'
      WHEN (month(d) =  6) THEN 'June'
      WHEN (month(d) =  7) THEN 'July'
      WHEN (month(d) =  8) THEN 'August'
      WHEN (month(d) =  9) THEN 'September'
      WHEN (month(d) = 10) THEN 'October'
      WHEN (month(d) = 11) THEN 'November'
      WHEN (month(d) = 12) THEN 'December'
    END);
  END;