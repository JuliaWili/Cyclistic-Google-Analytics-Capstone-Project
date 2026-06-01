/* GOOGLE ANALYTICS CAPSTONE PROJECT */
/* CYCLISTICS */

--------- DATA CLEANING ---------------------------------------------

/* combine 12 months of rides data into one table - Combined_Table */
USE Cyclistic
GO
SELECT * INTO Combined_Table FROM [Cyclistic].[dbo].[202504-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202505-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202506-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202507-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202508-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202509-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202510-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202511-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202512-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202601-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202602-divvy-tripdata]
UNION ALL
	SELECT * FROM [Cyclistic].[dbo].[202603-divvy-tripdata]

/* check number of entries in Combined_Table */
/* result: 5 620 544 */
SELECT COUNT(*) AS row_count FROM [Cyclistic].[dbo].[Combined_Table];

/* chceck for duplicates */
/*result: 5 620 544 */
/*conclusion: no duplicates */
SELECT COUNT(DISTINCT ride_id) AS ride_id_count FROM [Cyclistic].[dbo].[Combined_Table];

/* check type of users in member_casual column and which use the services more */ 
/*result: casual - 2 015 499; member - 3 605 045 */
/*conclusion: members use the service more */
SELECT member_casual, count(*) as user_count 
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual;

/* check types of rides and how many times they were used */
/*results: electric_bike - 3 678 925; classic_bike - 1 941 619*/
/*conclusion: electric bikes are used more */
SELECT rideable_type, count(*) as ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY rideable_type;

/* chceck start station names and how many rides started at them */
/* found 1 194 952 null results */
SELECT start_station_name, count(*) as ride_count 
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY start_station_name;

/* check if null start station values are related to the type o ride or type of user */
/* result: only electric bikes have null values in start_station_name */
SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS null_values_count
FROM [Cyclistic].[dbo].[Combined_Table]
WHERE start_station_name IS NULL
GROUP BY member_casual, rideable_type;

/* check if null start stations correlete with specific stations */
/* all rides with null values n start_station_name also have null values in start_station_id */
/* the rides probably started when the bike was left in a random place and was not parked in a specified parking dock */
SELECT
	start_station_id,
	COUNT(*) AS rides,
	SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS null_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY start_station_id
ORDER BY null_count DESC;

/* check if all the rides with null start_station_id have coordinates */
/* all rides have coordinates */
SELECT
	COUNT(*) AS null_station_rides,
	SUM(CASE WHEN start_lat IS NOT NULL AND start_lng IS NOT NULL THEN 1 ELSE 0 END) as has_coordinates,
	SUM(CASE WHEN start_lat IS NULL AND start_lng IS NULL THEN 1 ELSE 0 END) AS no_coordinates
FROM [Cyclistic].[dbo].[Combined_Table]
WHERE start_station_id IS NULL;

/*check values in end_station_name column */
/* found rides with null values */
SELECT end_station_name, count(*) as ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY end_station_name;

/*check if null valuesin end_station_name correlate to type of ride or type of user  */
/* most null values correspond with electric bikes but around 6k correspond with classic bikes */
SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS null_values_count
FROM [Cyclistic].[dbo].[Combined_Table]
WHERE end_station_name IS NULL
GROUP BY member_casual, rideable_type;

/* check if null end stations correlete with specific stations */
/* all rides with null values in end_station_name also have null values in end_station_id */
/* the rides probably ended with the bikeeing left in a random place and not in a specified parking dock */
SELECT
	end_station_id,
	COUNT(*) AS rides,
	SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS null_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY end_station_id
ORDER BY null_count DESC;

/* check if rides with null end_station_id have coordinates */
/* result: 5784 of rides do not have coordinates thus they are not valid rides (could be mistakes of the system) */
SELECT
	COUNT(*) AS null_station_rides,
	SUM(CASE WHEN end_lat IS NOT NULL AND end_lng IS NOT NULL THEN 1 ELSE 0 END) as has_coordiantes,
	SUM(CASE WHEN end_lat IS NULL AND end_lng IS NULL THEN 1 ELSE 0 END) AS no_coordinates
FROM [Cyclistic].[dbo].[Combined_Table]
WHERE end_station_id IS NULL;

/* remove the invalid rides with no end_station_id and no coordinates */
DELETE FROM [Cyclistic].[dbo].[Combined_Table]
WHERE end_station_id IS NULL AND (end_lat IS NULL AND end_lng IS NULL);

/* check if there are unnaturally long (over 24h) rides or unnaturally short (less then 1 minute) rides */
/* result: 202 187 rows*/
SELECT 
	member_casual,
	started_at,
	ended_at,
	DATEDIFF(MINUTE, started_at, ended_at) AS ride_length_in_min
FROM [Cyclistic].[dbo].[Combined_Table]
WHERE DATEDIFF(MINUTE, started_at, ended_at) <=1
OR DATEDIFF(MINUTE, started_at, ended_at) >= 1440
GROUP BY member_casual, started_at, ended_at;

/* remove rows with unnatural ride length */
DELETE FROM [Cyclistic].[dbo].[Combined_Table]
WHERE DATEDIFF(MINUTE, started_at, ended_at) <=1
OR DATEDIFF(MINUTE, started_at, ended_at) >= 1440;

/* check if there are rides where the start and end of the ride have the same coordinates */
/* result: 211 072 */
SELECT COUNT(*) AS stationary_rides
FROM [Cyclistic].[dbo].[Combined_Table] 
WHERE start_lat = end_lat AND start_lng = end_lng;

/* check the final row count */
/* result: 5 412 573 */
SELECT COUNT(*) FROM Combined_Table

-------- CREATING ADDITIONAL COLUMNS ------------------------------------------

/* create weekday column */
ALTER TABLE [Cyclistic].[dbo].[Combined_Table]
ADD week_day AS
	CASE DATEPART(WEEKDAY, started_at)
		WHEN 1 THEN 'Sunday'
		WHEN 2 THEN 'Monday'
		WHEN 3 THEN 'Tuesday'
		WHEN 4 THEN 'Wednesday'
		WHEN 5 THEN 'Thursday'
		WHEN 6 THEN 'Friday'
		WHEN 7 THEN 'Saturday'
END;

/* create month column */
ALTER TABLE [Cyclistic].[dbo].[Combined_Table]
ADD months AS
	CASE DATEPART(MONTH, started_at)
		WHEN 1 THEN 'January'
		WHEN 2 THEN 'February'
		WHEN 3 THEN 'March'
		WHEN 4 THEN 'April'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'June'
		WHEN 7 THEN 'July'
		WHEN 8 THEN 'August'
		WHEN 9 THEN 'September'
		WHEN 10 THEN 'October'
		WHEN 11 THEN 'November'
		WHEN 12 THEN 'December'
END

/* season column */
ALTER TABLE [Cyclistic].[dbo].[Combined_Table]
ADD Season as
	CASE DATEPART(MONTH,started_at)
		WHEN 1 THEN 'Winter'
		WHEN 2 THEN 'Winter'
		WHEN 3 THEN 'Spring'
		WHEN 4 THEN 'Spring'
		WHEN 5 THEN 'Spring'
		WHEN 6 THEN 'Summer'
		WHEN 7 THEN 'Summer'
		WHEN 8 THEN 'Summer'
		WHEN 9 THEN 'Autumn'
		WHEN 10 THEN 'Autumn'
		WHEN 11 THEN 'Autumn'
		WHEN 12 THEN 'Winter'
END

--------- ANALYSIS -----------------------------------------

/* temporary table of time of the day */
/* ride count and avg ride time based on type of user and time of day */
SELECT 
	member_casual,
	count(*) AS ride_count,
	CASE DATEPART(HOUR, started_at)
		WHEN 0 THEN '12 AM'
		WHEN 1 THEN '1 AM'
		WHEN 2 THEN '2 AM'
		WHEN 3 THEN '3 AM'
		WHEN 4 THEN '4 AM'
		WHEN 5 THEN '5 AM'
		WHEN 6 THEN '6 AM'
		WHEN 7 THEN '7 AM'
		WHEN 8 THEN '8 AM'
		WHEN 9 THEN '9 AM'
		WHEN 10 THEN '10 AM'
		WHEN 11 THEN '11 AM'
		WHEN 12 THEN '12 PM'
		WHEN 13 THEN '1 PM'
		WHEN 14 THEN '2 PM'
		WHEN 15 THEN '3 PM'
		WHEN 16 THEN '4 PM'
		WHEN 17 THEN '5 PM'
		WHEN 18 THEN '6 PM'
		WHEN 19 THEN '7 PM'
		WHEN 20 THEN '8 PM'
		WHEN 21 THEN '9 PM'
		WHEN 22 THEN '10 PM'
		WHEN 23 THEN '11 PM'
	END AS time_of_day,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, DATEPART(HOUR, started_at)
ORDER BY DATEPART(HOUR, started_at);

/* avg, min and max time of ride depending on ride type and type of user */
SELECT
	member_casual,
	rideable_type,
	COUNT(*) AS total_rides,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_time_in_min,
	MAX(DATEDIFF(MINUTE, started_at, ended_at)) AS max_ride_time_in_min,
	MIN(DATEDIFF(MINUTE, started_at, ended_at)) AS min_ride_time_in_min
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, rideable_type;

/* ride count per specific day */
SELECT
	CAST(started_at AS DATE) AS ride_date,
	COUNT(*) AS rides_per_day
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY CAST(started_at AS DATE) 
ORDER BY ride_date;

/* avg ride length by weekday */
SELECT 
	member_casual, 
	week_day, 
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, week_day
ORDER BY week_day, member_casual;

/* number of rides per weekday */
SELECT
	member_casual,
	week_day,
	count(*) AS number_of_rides
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, week_day
ORDER BY week_day, member_casual;

/* rides by season */
SELECT
	member_casual,
	Season,
	count(*) AS number_of_rides
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, Season
ORDER BY Season, member_casual;

/* ride length by season */
SELECT 
	member_casual,
	Season,
	AVG(DATEDIFF(MINUTE,started_at,ended_at)) AS avg_ride_length
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, Season
ORDER BY Season, member_casual;

/* rides by month */
SELECT 
	member_casual,
	months,
	COUNT(*) AS number_of_rides
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, months
ORDER BY months, member_casual;

/* average ride length by month */
SELECT 
	member_casual,
	months,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual, months
ORDER BY months, member_casual;

/* average ride length by users */
SELECT
	member_casual,
	AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual;

/* ride count by users */
SELECT
	member_casual,
	COUNT(*) AS ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual;

/* type of ride by members */
SELECT
	rideable_type,
	member_casual,
	count(*) AS ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY rideable_type, member_casual
ORDER BY member_casual, ride_count DESC;

/* counts of rides by start_station_names */
SELECT 
	start_station_name,
	member_casual,
	COUNT(*) AS ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY start_station_name, member_casual
ORDER BY start_station_name;

/* counts of rides by end_station_names */
SELECT 
	end_station_name,
	member_casual,
	COUNT(*) AS ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY end_station_name, member_casual
ORDER BY end_station_name;







	




















