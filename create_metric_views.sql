-- Creates metric view stations by hour
-- Calculates 3 metrics 1) Right First Time, 2) Utilisation and 3) Performance for each hour bucket

--- Creating View Split By Hour !!! note this is only managing buckets that span over one hour an not multiple hours, to be fixed later !!!
CREATE OR REPLACE VIEW GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.STATION_ACTIVITY_HISTORY_HOURLY AS
WITH RECURSIVE hourly_segments AS (
    SELECT 
        ID,
        STATION_ID,
        STATUS,
        START_DATE_TIME,
        END_DATE_TIME,
        LEAST(END_DATE_TIME, DATEADD(HOUR, 1, DATE_TRUNC('HOUR', START_DATE_TIME))) AS SEGMENT_END,
        TARGET_QUANTITY,
        ACTUAL_QUANTITY,
        DEFECTS,
        DOWNTIME_REASON
        , DATEDIFF(SECOND, START_DATE_TIME, LEAST(END_DATE_TIME, DATEADD(HOUR, 1, DATE_TRUNC('HOUR', START_DATE_TIME)))) 
/ NULLIF(DATEDIFF(SECOND, START_DATE_TIME, END_DATE_TIME), 0) AS PROPORTION
    FROM 
        GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.STATION_ACTIVITY_HISTORY
        
    UNION ALL
    
    SELECT 
        CONCAT (ID,'.01') as ID ,
        STATION_ID,
        STATUS,
        SEGMENT_END AS START_DATE_TIME,
        END_DATE_TIME,
        LEAST(END_DATE_TIME, DATEADD(HOUR, 1, DATE_TRUNC('HOUR', SEGMENT_END))) AS SEGMENT_END,
        TARGET_QUANTITY,
        ACTUAL_QUANTITY,
        DEFECTS,
        DOWNTIME_REASON,
        DATEDIFF(SECOND, SEGMENT_END, LEAST(END_DATE_TIME, DATEADD(HOUR, 1, DATE_TRUNC('HOUR', SEGMENT_END))))
/ NULLIF(DATEDIFF(SECOND, START_DATE_TIME, END_DATE_TIME), 0) AS PROPORTION
    FROM 
        hourly_segments
    WHERE 
        SEGMENT_END < END_DATE_TIME
)

SELECT 
    ID,
    STATION_ID,
    STATUS,
    START_DATE_TIME,
    SEGMENT_END AS END_DATE_TIME,
    DATEDIFF(SECOND, START_DATE_TIME, SEGMENT_END) AS DURATION,
    ROUND((PROPORTION) * TARGET_QUANTITY) AS TARGET_QUANTITY,
    ROUND((PROPORTION) * ACTUAL_QUANTITY) AS ACTUAL_QUANTITY,
    ROUND((PROPORTION) * DEFECTS) AS DEFECTS,
    DOWNTIME_REASON
FROM 
    hourly_segments
ORDER BY
    ID,
    START_DATE_TIME;

Select * from STATION_ACTIVITY_HISTORY_HOURLY
order by START_DATE_TIME ASC;

-- Creating Metrics View for right first time, performance and utilisation
CREATE OR REPLACE VIEW GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.STATION_HOURLY_METRICS AS
WITH hourly_data AS (
    SELECT
        STATION_ID,
        DATE_TRUNC('HOUR', START_DATE_TIME) AS hour_start,
        CASE WHEN Status = 'RUNNING' THEN SUM(DURATION) ELSE 0 END AS RUNNING_TIME,
        CASE WHEN Status = 'DOWN' THEN SUM(DURATION) ELSE 0 END AS DOWN_TIME,
        SUM(TARGET_QUANTITY) AS TARGET_QUANTITY,
        SUM(ACTUAL_QUANTITY) AS ACTUAL_QUANTITY,
        SUM(DEFECTS) AS DEFECTS
    FROM
        GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.STATION_ACTIVITY_HISTORY_HOURLY
    GROUP BY
        STATION_ID,
        DATE_TRUNC('HOUR', start_date_time),
        STATUS
),

calculations AS (
    SELECT
        STATION_ID,
        hour_start,
        SUM(RUNNING_TIME) AS RUNNING_TIME,
        SUM(DOWN_TIME) AS DOWN_TIME,
        3600 - SUM(RUNNING_TIME + DOWN_TIME) AS Non_Recorded_Time,
        SUM(Target_Quantity) AS Target_Quantity,
        SUM(Actual_Quantity) AS Actual_Quantity,
        SUM(Defects) AS Defects,
        SUM(RUNNING_TIME) / 3600 AS Utilisation,
        CASE 
            WHEN SUM(Actual_Quantity) <> 0 
            THEN (SUM(Actual_Quantity) - SUM(Defects)) / SUM(Actual_Quantity) 
            ELSE NULL 
        END AS Right_First_Time,
        CASE 
            WHEN SUM(Target_Quantity) <> 0 
            THEN SUM(Actual_Quantity) / SUM(Target_Quantity) 
            ELSE NULL 
        END AS Performance
    FROM
        hourly_data
    GROUP BY
        Station_ID,
        hour_start
)

SELECT
    Station_ID,
    hour_start,
    RUNNING_TIME,
    DOWN_TIME,
    Non_Recorded_Time,
    Target_Quantity,
    Actual_Quantity,
    Defects,
    Utilisation,
    Right_First_Time,
    Performance
FROM
    calculations
ORDER BY
    Station_ID,
    hour_start;

select * from GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.STATION_HOURLY_METRICS;

-- Downtime view
CREATE OR REPLACE VIEW GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.DOWN_TIME_REASONS AS
SELECT
    STATION_ID AS Station_ID,
    START_DATE_TIME AS Start_Date,
    DURATION,
    COALESCE(DOWNTIME_REASON, 'unknown') AS Down_Time_Reason
FROM
    GLOBAL_PRODUCTION.TULIP_COMMON_DATA_MODEL.STATION_ACTIVITY_HISTORY
WHERE
    STATUS = 'DOWN';

-- Downtime Perato
Select 
    DOWN_TIME_REASON
    , sum(duration)
    from DOWN_TIME_REASONS
    Group by DOWN_TIME_REASON
    Order By sum(duration) desc
    ;
