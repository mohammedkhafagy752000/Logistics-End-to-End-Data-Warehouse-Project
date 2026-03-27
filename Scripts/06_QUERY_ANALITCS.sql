USE LOGISTIC_DWH;
-- KPIs--
SELECT 
COUNT(Tripkey)AS NUMBER_OF_TRIPS,
SUM(revenue) AS TOTAT_OF_REVENUE,
SUM(pieces)AS NUMBER_OF_PIECES,
SUM(weight_lbs) AS TOTAL_WEIGHTS
FROM FACT_TRIPS ; 

-- A report showing me the top 5 drivers in terms of “punctuality” during the year 2023
SELECT TOP(5) (f_name +' ' + l_name) AS FULLNAME,COUNT(FT.Driverkey) AS NUBERS_OF_TRIPS,(SUM(CAST(on_time_flag AS FLOAT)) / COUNT(*)) * 100 AS ON_TIMERATE
FROM FACT_TRIPS FT
JOIN DIM_DRIVER DD ON FT.Driverkey=DD.DRIVERKEY
JOIN DIM_DATE DAT ON FT.Datekey=DAT.DateKey
WHERE DAT.FullDate >= '2
023-01-01' AND DAT.FullDate <= '2023-12-31'
GROUP BY FT.Driverkey, DD.f_name,DD.l_name
ORDER BY ON_TIMERATE DESC ;     -- DONE --> Jennifer Miller ACHIVED TOP  VALUE OF ON_TIMERATE 40.3% THAT IN FACT IS VERY DOWN

--Where does our money go? There are certain routes, and I suspect that the fuel consumption there is very high and this will cause us loss?!
SELECT TOP(3) DR.origin_city,DR.destination_city,AVG(FT.average_mpg) AS MEAN_MPG
FROM FACT_TRIPS FT 
JOIN DIM_ROUTES DR ON FT.RoutesKey=DR.RoutesKey
GROUP BY FT.RoutesKey,DR.origin_city,DR.destination_city
ORDER BY  MEAN_MPG ASC;    -- DONE --> Long-haul routes from Houston (to Seattle and Portland) and from Dallas to Indianapolis are the worst efficient with an MPG of close to 6.47.

--Are the trucks we neglect to maintain causing accidents?
WITH TRUCKINCIDENTS AS (
SELECT Truckkey,SUM(vehicle_damage_cost ) AS TOTALDAMAGECOST,
COUNT(incident_id) AS INCIDENTCOUNT
FROM FACT_INCIDENTS 
GROUP BY Truckkey
HAVING COUNT(incident_id)>1
),
TRUCKMAINTANCE AS(
SELECT TruckKey,SUM(total_cost) AS TOTALCOST 
FROM FACT_MAINTENANCE
GROUP BY TruckKey)

SELECT DT.unit_number,TI.TOTALDAMAGECOST,TM.TOTALCOST 
FROM TRUCKINCIDENTS TI
LEFT JOIN TRUCKMAINTANCE TM ON TI.TruckKey=TM.TruckKey
JOIN DIM_TRUCKS DT ON TI.TruckKey=DT.TruckKey;


-- GET THE DRIVER JOCKER INSIDE EVERY STATE VIA revenue
WITH TOP3DRIVER AS(
SELECT 
 DR.origin_state,(DD.f_name+ ' '+DD.l_name) AS DRIVERNAME,SUM(FT.revenue) AS TOTALrevenue,
 ROW_NUMBER() OVER (PARTITION BY DR.origin_state ORDER BY SUM(FT.revenue)DESC) AS _ROW_NUMBER,
 RANK() OVER (PARTITION BY DR.origin_state ORDER BY SUM(FT.revenue)DESC) AS _RANK,
 DENSE_RANK() OVER (PARTITION BY DR.origin_state ORDER BY SUM(FT.revenue)DESC) AS _DENSE_RANK
 FROM FACT_TRIPS FT 
 JOIN DIM_DRIVER DD ON FT.Driverkey=DD.DRIVERKEY
 JOIN DIM_ROUTES DR ON FT.RoutesKey=DR.RoutesKey
 GROUP BY DR.origin_state, DD.f_name,DD.l_name)
 SELECT origin_state,DRIVERNAME,TOTALrevenue,_DENSE_RANK
 FROM TOP3DRIVER
 WHERE _DENSE_RANK<=3
 ORDER BY origin_state ;
 
 --Whether the driver’s performance has improved or deteriorated compared to his previous trip?
 SELECT (DD.f_name +' '+DD.l_name) AS DRIVERNAME,FT.revenue AS CURRENT_REVENUE, 
 LEAD ( FT.revenue) OVER (PARTITION BY FT.DRIVERKEY ORDER BY FT.DATEKEY ASC) AS NEXT_revenue,
 LAG(FT.revenue) OVER (PARTITION BY FT.DRIVERKEY ORDER BY FT.DATEKEY ASC ) AS PERVIOUS_REVENUE,
 FT.revenue-LAG(FT.revenue) OVER (PARTITION BY FT.DRIVERKEY ORDER BY FT.DATEKEY ASC ) AS REVENUE_DIFFERENCE
 FROM FACT_TRIPS FT 
 JOIN DIM_DRIVER DD ON FT.Driverkey=DD.DRIVERKEY;

 -- Track the total amount we spent on maintaining each truck since it started operating, to know the moment when the truck started to become a financial burden?
 SELECT DateKey,TruckKey,
 SUM(total_cost) OVER (PARTITION BY TruckKey ORDER BY DateKey ASC) AS Cumulative_Maintenance_Cost
 FROM FACT_MAINTENANCE; 

 --Which driver burns more fuel than the average of his colleagues in the same state
 SELECT (DD.f_name +' '+ DD.l_name) AS DRIVERNAME,DR.origin_state,
 AVG(AVG(FT.average_mpg)) OVER (PARTITION BY origin_state) AS AVG_MPG_STATE,
 AVG(FT.average_mpg)-AVG(AVG(FT.average_mpg)) OVER (PARTITION BY origin_state)  AS DIFF_MPG
 FROM FACT_TRIPS FT 
 JOIN DIM_DRIVER DD ON FT.Driverkey=DD.DRIVERKEY
 JOIN DIM_ROUTES DR ON FT.RoutesKey=DR.RoutesKey
 GROUP BY DD.f_name,DD.l_name,DR.origin_state;
 -- GET NO. TRIPS, SUM OF RENENUE FOR EACH STATE
 SELECT  DR.origin_state, COUNT(Tripkey) AS NO_TRIPS,SUM(FT.revenue) AS TOTAL_REVENUE,
 DENSE_RANK() OVER ( ORDER BY SUM(FT.revenue) DESC) AS DENSE_R
 FROM FACT_TRIPS FT
 JOIN DIM_ROUTES DR ON FT.RoutesKey=DR.RoutesKey
 GROUP BY DR.origin_state;
 -- SELECT THE TRIPS WHICH ITS WEIGHT > AVG. WEIGHT
 SELECT * 
 FROM FACT_TRIPS
 WHERE weight_lbs>(SELECT AVG(weight_lbs) FROM FACT_TRIPS);
 -- QUERY THE DRIVERS THAT ACHIEVE REVENUE >100,000$
 WITH DRIVERS_REVENEUE AS(
 SELECT DD.driver_id,DD.f_name+' '+ DD.l_name AS FULLNAME,SUM(FT.revenue) AS TOTAL_REVENUE
 FROM FACT_TRIPS FT 
 JOIN DIM_DRIVER DD ON FT.Driverkey=DD.DRIVERKEY
 GROUP BY DD.f_name,DD.l_name,DD.driver_id)
 SELECT FULLNAME,TOTAL_REVENUE 
 FROM DRIVERS_REVENEUE
 WHERE TOTAL_REVENUE>100000;
 --- SELECT 1,2 TOP 2 STATE ACHIEVE BEST REVENUE SEPARATELY AND UNION ALL
 WITH TOP1 AS(
 SELECT  DM.origin_state, SUM(FT.revenue) AS TOTAL_REVENUE,
 DENSE_RANK() OVER(ORDER BY SUM(FT.revenue) DESC) AS DENSE_R
 FROM FACT_TRIPS FT
 JOIN DIM_ROUTES DM ON FT.RoutesKey=DM.RoutesKey
 GROUP BY DM.origin_state)
 SELECT origin_state,TOTAL_REVENUE
 FROM TOP1 WHERE DENSE_R>=1 AND DENSE_R<=10
 UNION         --UNION ALL, EXCEPT,INTERSECT
 SELECT origin_state,TOTAL_REVENUE
 FROM TOP1 WHERE DENSE_R>=1 AND DENSE_R<=5
 ORDER BY TOTAL_REVENUE DESC;
 -- CREATE VIEW SUMMARIZE THE PERFORMANE FOR EACH STATE
 CREATE VIEW STATE_REPORT AS
 SELECT DM.origin_state,SUM(FT.revenue) AS TOTAL_REVENUE,COUNT(FT.Tripkey) AS NO_TRIPS,AVG(FT.average_mpg) AS AVG_MPG,COUNT(DISTINCT(DC.customer_id)) AS NO_CUSTOMERS
 FROM FACT_TRIPS FT
 JOIN DIM_ROUTES DM ON FT.RoutesKey=DM.RoutesKey
 JOIN DIM_CUSTOMERS DC ON FT.Customerkey=DC.CustomerKey
 GROUP BY DM.origin_state;
 -- STRING FUNCTIONS
 SELECT RIGHT( unit_number,3) AS TRUCK_UN,UPPER(SUBSTRING(unit_number,1,3)) FROM DIM_TRUCKS; --LEFT,RIGHT,LOWER,UPPER
 SELECT CONCAT(MAKE, '/',unit_number) AS MAKE_UNIT_N, LEN(make)
 FROM DIM_TRUCKS;
  -- QUERY DRIVERS THAT BEGIN BY B AND END WITH a
  SELECT f_name
  FROM DIM_DRIVER
  WHERE f_name LIKE 'B%a' OR f_name LIKE 'S___h';
  -- query the trips in q3 2023
  SELECT *, DDT.Quarter,DDT.Year
  FROM FACT_TRIPS FT
  JOIN DIM_DATE DDT ON FT.Datekey=DDT.DateKey
  WHERE DDT.Quarter=3 AND DDT.Year=2023;
 -- GET TRUCKS WHICH GET >MAINTANCE IN < 15 DAY  
   SELECT DISTINCT 
    M1.TruckKey, 
    D1.FullDate AS First_Maintenance_Date, 
    'Needs Attention' AS Reliability_Issue
FROM FACT_MAINTENANCE M1
JOIN FACT_MAINTENANCE M2 ON M1.TruckKey = M2.TruckKey
JOIN DIM_DATE D1 ON M1.DateKey = D1.DateKey 
JOIN DIM_DATE D2 ON M2.DateKey = D2.DateKey 
WHERE M1.MaintenanceKey <> M2.MaintenanceKey
AND DATEDIFF(DAY, D1.FullDate, D2.FullDate) BETWEEN 1 AND 15; 
-- DETECT LEVEL OF EXPERIENCE FOR EACH DRIVER DEPEND ON NO. EXPERIENCE YEAR
SELECT DRIVERKEY,driver_id, f_name,l_name,years_experience,
CASE 
WHEN years_experience BETWEEN 0 AND 2 THEN 'MID'
WHEN years_experience BETWEEN 3 AND 5 THEN 'SEN'
ELSE 'SUPER'END AS EXPERIENCE_LEVEL
FROM DIM_DRIVER;

-- PIVOT: FOR EACH TRUCK CALCULATE SUM REVENUE IN EACH QUARTER
SELECT Truckkey, [1] AS Q1_Rev, [2] AS Q2_Rev, [3] AS Q3_Rev, [4] AS Q4_Rev
FROM (
    SELECT FT.revenue, FT.Truckkey, DDT.Quarter
    FROM FACT_TRIPS FT
    JOIN DIM_DATE DDT ON FT.Datekey = DDT.DateKey
    WHERE DDT.Year = 2023
) AS SourceTable
PIVOT (
    SUM(revenue)
    FOR Quarter IN ([1], [2], [3], [4])
) AS PivotResult;
