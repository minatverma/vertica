--
-- month to name function with decode
--
CREATE OR REPLACE FUNCTION month_name(month_num INT)
RETURN VARCHAR(10)
  AS BEGIN
    RETURN Decode(month_num,
	1,'January',
	2,'February',
	3,'March',
	4,'April',
	5,'May',
	6,'June',
	7,'July',
	8,'August',
	9,'September',
	10,'October',
	11,'November',
	12,'December');
  END;


--
-- month to name function with case else
--
CREATE OR REPLACE FUNCTION month_name2(month INT)
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
