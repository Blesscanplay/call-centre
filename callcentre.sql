/*
These SQL queries are written to clean PHONENOW's call centre datasets.
I have created a schema called callcentre which houses the working table "calls"
*/

-- to select the specific database we'll be using for this task
USE callcentre;

-- to display the table that contains the callcentre data and have more specific look at the data content and columns
SELECT * FROM calls;
SELECT DISTINCT month FROM calls;
SELECT DISTINCT Year FROM calls;
SELECT DISTINCT agent FROM calls;
SELECT DISTINCT topic FROM calls;
SELECT DISTINCT satisfaction_rating FROM calls;
SELECT COUNT(*) FROM calls WHERE answered_calls= 'no';


-- to show the number of rows contained in the calls datasets
SELECT COUNT(call_id) FROM calls;

-- to see if the call ids are unique and can be used as the primary key
SELECT COUNT(distinct call_id) FROM calls;

-- to check out the data types of each column
SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'callcentre' AND table_name ='calls';

-- To rename columns to make them clearer and change column names that have space inbetween
ALTER TABLE calls RENAME COLUMN `call id` TO call_id;
ALTER TABLE calls RENAME COLUMN `Speed of answer in seconds` TO answer_speed_secs;
ALTER TABLE calls RENAME COLUMN `Satisfaction rating` TO satisfaction_rating;
ALTER TABLE calls RENAME COLUMN `Answered (Y/N)` TO answered;

-- to change the data types to the most appropriate ones
ALTER TABLE calls MODIFY COLUMN call_id VARCHAR(50) PRIMARY KEY UNIQUE;
ALTER TABLE calls MODIFY COLUMN Date date;
ALTER TABLE calls MODIFY COLUMN Time time;
ALTER TABLE calls MODIFY COLUMN AvgTalkDuration time;
ALTER TABLE calls MODIFY COLUMN agent VARCHAR(50);
ALTER TABLE calls MODIFY COLUMN topic VARCHAR(50);
ALTER TABLE calls MODIFY COLUMN answered VARCHAR(50);
ALTER TABLE calls MODIFY COLUMN resolved VARCHAR(50);

-- to confirm the consistency of data. 
-- The length of data entered can be used to confirm that they are of the same pattern.
SELECT length(date), max(length(date)), min(length(date)) FROM calls;
SELECT length(Time), max(length(Time)), min(length(Time)) FROM calls;
SELECT length(AvgTalkDuration), max(length(AvgTalkDuration)), min(length(AvgTalkDuration)) FROM calls;
SELECT length(satisfaction_rating), max(length(satisfaction_rating)), min(length(satisfaction_rating)) FROM calls;

-- to confirm that we have only Y and N inputs in the answered and resolved columns
SELECT DISTINCT answered FROM calls;
SELECT DISTINCT Resolved FROM calls;

-- to change Y to YES and N to NO in answered column using CASE statement
SELECT answered, CASE WHEN answered = 'Y' THEN 'YES'
			WHEN answered = 'N' THEN 'NO'
            ELSE answered END AS Answered_calls
FROM calls;

-- add the answered calls column to the table
ALTER TABLE calls
ADD Answered_calls varchar(50) AFTER answered;

-- update the table with the new values YES and NO using the CASE statement
UPDATE calls 
SET Answered_calls = (CASE WHEN answered = 'Y' THEN 'YES'
			WHEN answered = 'N' THEN 'NO'
            ELSE answered END);
            
-- to change Y to YES and N to NO in resolved column using CASE statemnet
SELECT resolved, CASE WHEN Resolved = 'Y' THEN 'YES'
			WHEN Resolved = 'N' THEN 'NO'
            ELSE Resolved END AS resolved_calls
FROM calls;

-- add the resolved calls column to the table
ALTER TABLE calls
ADD Resolved_calls varchar(50) AFTER resolved;

-- update the table with the new values YES and NO using the CASE statement
UPDATE calls 
SET Resolved_calls = (CASE WHEN Resolved = 'Y' THEN 'YES'
			WHEN Resolved = 'N' THEN 'NO'
            ELSE Resolved END );

-- check if there are missing values
select * from calls where call_id is null;      

-- Using CTE and window function to check for duplicate rows
WITH dup AS 
			(SELECT *,row_number() OVER(PARTITION BY call_id,agent,Date, Time, topic, answered, 
            resolved,AvgTalkDuration,satisfaction_rating ORDER BY call_id) rownum
				FROM calls)
SELECT count(*) FROM dup
	WHERE rownum > 1;
    
-- to extract the year out of the dates column and create a new column for it

SELECT EXTRACT(YEAR FROM Date) FROM calls;

ALTER TABLE calls 
ADD COLUMN Year year AFTER Date;

UPDATE calls 
SET Year = EXTRACT(YEAR FROM Date);

-- to extract the month out of the dates column and create a new column for it

SELECT  MONTHNAME(Date) FROM calls;

ALTER TABLE calls
ADD COLUMN Monthname varchar(15) AFTER Year;

UPDATE calls 
SET Monthname = MONTHNAME(Date) ;

-- changed column monthname to month
ALTER TABLE calls
RENAME COLUMN Monthname TO Month;

-- to extract day number from the dates column and create a new column for it
SELECT EXTRACT(DAY FROM Date) FROM calls;

ALTER TABLE calls
ADD COLUMN Day int  AFTER Month;

UPDATE calls 
SET Day = EXTRACT(DAY FROM Date) ;

-- to extract the weekday name out of the dates column and create a new column for it
SELECT DAYNAME(Date) FROM calls;

ALTER TABLE calls
ADD COLUMN Dayname varchar(15) AFTER Day;

UPDATE calls 
SET Dayname = DAYNAME(Date);

-- to convert the time duration to seconds and create a new column for it
SELECT TIME_TO_SEC(avgtalkduration) FROM calls;

ALTER TABLE calls
ADD  COLUMN Avgtalkduration_in_secs int AFTER avgtalkduration;

UPDATE calls
SET Avgtalkduration_in_secs = TIME_TO_SEC(avgtalkduration);

-- To delete columns that are not relevant to the data analysis
ALTER TABLE calls DROP COLUMN answered;
ALTER TABLE calls DROP COLUMN resolved;
ALTER TABLE calls DROP COLUMN avgtalkduration;
ALTER TABLE calls DROP COLUMN Year;

--  a final look at the already cleaned data
SELECT * FROM calls;