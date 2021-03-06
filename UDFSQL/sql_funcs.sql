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
-- Converts month order number to full name
-- @month  - moth number candidate
-- @return - month name iff month number is valid otherwise null
------
CREATE OR REPLACE FUNCTION month_name(month INT)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN (CASE month
      WHEN  1  THEN 'January'
      WHEN  2  THEN 'February'
      WHEN  3  THEN 'March'
      WHEN  4  THEN 'April'
      WHEN  5  THEN 'May'
      WHEN  6  THEN 'June'
      WHEN  7  THEN 'July'
      WHEN  8  THEN 'August'
      WHEN  9  THEN 'September'
      WHEN 10  THEN 'October'
      WHEN 11  THEN 'November'
      WHEN 12  THEN 'December'
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


------ 
-- Converts weekday order number to full name
-- @weekday  - weekday number candidate
-- @return   - weekday name iff weekday number is valid otherwise null
------
CREATE OR REPLACE FUNCTION weekday_name(weekday INT)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN (CASE weekday
      WHEN  1  THEN 'Sunday'
      WHEN  2  THEN 'Monday'
      WHEN  3  THEN 'Tuesday'
      WHEN  4  THEN 'Wednesday'
      WHEN  5  THEN 'Thursday'
      WHEN  6  THEN 'Friday'
      WHEN  7  THEN 'Saturday'
    END);
  END;


------ 
-- Extracts week day from DATE.
-- @dt     - date candidate
-- @return - week day iff week day number is valid otherwise null
------
CREATE OR REPLACE FUNCTION weekday_name(dt DATE)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN weekday_name(DAYOFWEEK(dt));
  END;


------ 
-- Extracts week day from TIMESTAMP.
-- @ts     - timestamp candidate
-- @return - week day iff week day number is valid otherwise null
------
CREATE OR REPLACE FUNCTION weekday_name(ts TIMESTAMP)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN weekday_name(DAYOFWEEK(ts));
  END;


------ 
-- Returns random timestamp between 2 other timestamps
-- @ts1    - lower bound timestamp candidate
-- @ts2    - upper bound timestamp candidate
-- @return - random timestamp between LowB and UpB
------
CREATE OR REPLACE FUNCTION random_ts(ts1 TIMESTAMP, ts2 TIMESTAMP)
RETURN TIMESTAMP
  AS BEGIN
    RETURN TO_TIMESTAMP( 
               EXTRACT(EPOCH FROM ts1) + 
               RANDOMINT(FLOOR(@ EXTRACT(EPOCH FROM ts2) - EXTRACT(EPOCH FROM ts1))::INT));
  END;

------ 
-- Returns midpoint timestamp
-- @s      - from timestamp candidate
-- @e      - to timestamp candidate
-- @return - midpoint timestamp
------
CREATE OR REPLACE FUNCTION midpoint_timestamp(s timestamp, e timestamp)
RETURN TIMESTAMP
  AS BEGIN
      RETURN TO_TIMESTAMP((EXTRACT(epoch from s) + EXTRACT(epoch from e))/2.0);
  END;


-------------------------------------------------------------------------------
--- Returns years season (winter, spring, summer, autumn)
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION season(month_num INTEGER)
RETURN VARCHAR(10)
AS BEGIN
  RETURN (CASE
      WHEN (month_num % 12 <  3) THEN 'Winter'
      WHEN (month_num      <  6) THEN 'Spring'
      WHEN (month_num      <  9) THEN 'Summer'
      WHEN (month_num      < 12) THEN 'Fall'
    END);
  END;

CREATE OR REPLACE FUNCTION season(dt DATE)
RETURN VARCHAR(10)
AS BEGIN
  RETURN season(MONTH(dt));
  END;

CREATE OR REPLACE FUNCTION season(ts TIMESTAMP)
RETURN VARCHAR(10)
AS BEGIN
  RETURN season(MONTH(ts));
  END;

CREATE OR REPLACE FUNCTION season(tsz TIMESTAMPTZ)
RETURN VARCHAR(10)
AS BEGIN
  RETURN season(MONTH(tsz));
  END;


-------------------------------------------------------------------------------
---   Returns if year is leap
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION is_leap_year(year INTEGER)
RETURN BOOLEAN
AS BEGIN
  RETURN (year % 4 = 0 AND (year % 100 = 0 OR year %400 <> 0));
  END;

CREATE OR REPLACE FUNCTION is_leap_year(dt DATE)
RETURN BOOLEAN
AS BEGIN
  RETURN is_leap_year(YEAR(dt));
  END;

CREATE OR REPLACE FUNCTION is_leap_year(ts TIMESTAMP)
RETURN BOOLEAN
AS BEGIN
  RETURN is_leap_year(YEAR(ts));
  END;

CREATE OR REPLACE FUNCTION is_leap_year(tsz TIMESTAMPTZ)
RETURN BOOLEAN
AS BEGIN
  RETURN is_leap_year(YEAR(tsz));
  END;

-------------------------------------------------------------------------------
--- Returns quarter day
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION current_quarter_last_day()
RETURN TIMESTAMP
  AS BEGIN
      RETURN CASE ((MONTH(SYSDATE()) - 1) // 3 + 1)
                  WHEN 1 THEN (YEAR(SYSDATE()) || '-03-31 23:59:59')::TIMESTAMP
                  WHEN 2 THEN (YEAR(SYSDATE()) || '-06-30 23:59:59')::TIMESTAMP
                  WHEN 3 THEN (YEAR(SYSDATE()) || '-09-30 23:59:59')::TIMESTAMP
                  WHEN 4 THEN (YEAR(SYSDATE()) || '-12-31 23:59:59')::TIMESTAMP
              END;
  END;