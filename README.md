# Cyclistic-Google-Analytics-Capstone-Project
PL VER

Case study  badające różnice w zachowaniu użytkowników okazjonalnych i subskrybentów rocznych rowerów miejskich Cyclistic.

ENG VER

A data analytics case study examining Cyclistic bike-share data to identify behavioral differences between casual riders and annual members. 

The file 'ENG_SQL_script.sql' contains the SQL code for the project.

The 'Dashboard.pbix; contains the Power BI dashboard with visualizations of the data.

# Background
I am a junior data analyst working in the marketing analyst team at Cyclistic, a fictitious bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, my team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, my team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve my recommendations, so they must be backed up with compelling data insights and professional data visualizations.

The datasets for this project were made available by Motivate International Inc.

# Business Task and Objective
The business task is to get an understanding on how annual members and casual riders use Cyclistic bike services differently. My aim is to analyze historical bike trip data, identify patterns and trends fo both groups of users. The insights gained from this analysis will be instrumental in designing new marketing startegy aimd at converting casual riders into annual members, thus maximizing the company's profit and contributing to its future growth. 

The analysis will include data cleaning and manipualtion, visualizations, key findings and three best recommendations based on the conducted analysis.

# Data Collection
I will be using Cyclistic's historical trip data from April of 2025 to March 2026.  The data has been made available by Motivate International Inc. However, data-privacy issues prohibit the use of riders’ personally identifiable information. 

Each of the 12 data files is organized into rows, with one row representing one ride trip. The table details are show in the table below:

| FIELDS | DATA_TYPE | DESCRIPTION | NULLABLE |
|--------|-----------|-------------|----------|
| ride_id | nvarchar | text | NO |
| rideable_type | nvarchar | text | NO |
| started_at | datetime2 | Date-Time | YES |
| ended_at | datetime2 | Date-Time | YES |
| start_station_name | varchar | text | YES |
| start_station_id | nvarchar | text | YES |
| end_station_name | varchar | text | YES |
| end_station_id | nvarchar | text | YES |
| start_lat | varchar | text | YES |
| start_lng | varchar | text | YES |
| end_lat | varchar | text | YES |
| end_lng | varchar | text | YES |
| member_casual | nvarchar | text | NO |
| week_day | varchar | text | YES |
| months | varchar | text | YES |
| Season | varchar | text | YES |

After importing all 12 files into MS SQL, I merged the tables into one Combined Table using the UNION ALL statements.

#Data Cleaning
To start the claning process, I checked the amout of entries in the table with SELECT COUNT statement.

```sql
SELECT COUNT(*) AS row_count FROM [Cyclistic].[dbo].[Combined_Table];
```

The result yielded 5 620 544 rows.

Then I investigates for duplicates by counting distinct ride_ids.

```sql
SELECT COUNT(DISTINCT ride_id) AS ride_id_count FROM [Cyclistic].[dbo].[Combined_Table];
```

The result yielded count of 5 620 544 entries. Since the number is the same as the count of all rows it means there are no duplicate entries in the table.

Then I checked the type of users in member_casual column and which type of user uses the services more.

```sql
SELECT member_casual, count(*) as user_count 
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY member_casual;
````

The query found the following result:

| member_casual | user_count | 
|--------|-----------|
| casual | 2 015 499| 
| member | 3 605 045|

Then I checked the types of rides in rideable_type column and which type is used the most.

```sql
SELECT rideable_type, count(*) as ride_count
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY rideable_type;
```

The query yieled following result:

| rideable_type | ride_count | 
|--------|-----------|
| electric_bike | 3 678 925 | 
| classic_bike | 1 941 619|

Next, I checked start_station_name column and how many rides started at each station. The query revealed that 1 194 952 rides do not start at any particular station and their value in start_station_name is NULL. 

```sql
SELECT start_station_name, count(*) as ride_count 
FROM [Cyclistic].[dbo].[Combined_Table]
GROUP BY start_station_name;
```




