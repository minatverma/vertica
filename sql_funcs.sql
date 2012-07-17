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


------ 
-- Converts weekday order number to full name
-- @weekday  - weekday number candidate
-- @return   - weekday name iff weekday number is valid otherwise null
------
CREATE OR REPLACE FUNCTION weekday_name(weekday INT)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN (CASE
      WHEN (weekday = 1) THEN 'Sunday'
      WHEN (weekday = 2) THEN 'Monday'
      WHEN (weekday = 3) THEN 'Tuesday'
      WHEN (weekday = 4) THEN 'Wednesday' 
      WHEN (weekday = 5) THEN 'Thursday'
      WHEN (weekday = 6) THEN 'Friday'
      WHEN (weekday = 7) THEN 'Saturday' 
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