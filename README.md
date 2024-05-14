# Dano Airline Passengers Satisfaction Report

### Table of Contents
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools used for Analysis](#tools-used-for-analysis)
- [Data Cleaning](#data-cleaning)
- [Problem Statement](#problem-statement)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Recommendation](#recommendation)

## Project Overview
Dano Airline is a UK-based airline. The latest customer survey results revealed a decline in satisfaction rate falling below 50% for the first time ever. The objective of this analysis is to find patterns and trends to help improve the various services rendered by the airline and boost passengers satisfaction.
**_Disclaimer_**: _All datasets and report do not represent any company, institution or country, but just a dummy dataset to demonstrate capabilities of Sql._**
 
## Data Source
This is the primary dataset used for this analysis "Airline_data_airline_passenger rating.csv" file [download here](https://docs.google.com/spreadsheets/d/15Kp-2yfQFNRGJPNOkpMwG-OMX8xVZOJ5VL7f35v7sRQ/edit#gid=1647986900)

## Tools Used for Analysis
-  SQL Server for Exploratory Data Analysis.
-  Power BI for Data Visualization and Reports.

 ## Data Cleaning
 - Data Loading and Transformation; Arrival delay had 393 Nulls, and Median was used to correct this errors
-  Data Validation.
  
## Problem Statement
- How many passengers are satisfied/dissatisfied when depature delay and arrival delay is less than or equal to 60 minutes and more than 60 minutes?
- Is there a correlation between any of the services rendered by the airline?
- flight distance by satisfaction less than 800 miles and more than or equal to 800 miles
- How many passengers are Satisfied/dissatisfied with depature and arrival time convenience?
- What is the passengers count by age group?
- Whats the average rating of each service?


## Exploratory Data Analysis
```sql
SELECT * FROM Dano_airline

--- Creating a new column Age_range to input Age into segments
ALTER TABLE Dano_airline
ADD Age_range NVARCHAR (50)

UPDATE Dano_airline
SET Age_range = CASE
    WHEN Age BETWEEN 7 AND 12 THEN '7-12'
    WHEN Age BETWEEN 13 AND 19 THEN '13-19'
    WHEN Age BETWEEN 20 AND 35 THEN '20-35'
    WHEN Age BETWEEN 36 AND 55 THEN '36-55'
	WHEN Age BETWEEN 56 AND 85 THEN '56-85'
    END

---Creating a new column Age_group to input Age Range into category
ALTER TABLE Dano_airline
ADD Age_group VARCHAR (50)

UPDATE Dano_airline
SET Age_group = CASE
      WHEN Age BETWEEN 7 AND 12 THEN 'Adolescent'
      WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
      WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
      WHEN Age BETWEEN 36 AND 55 THEN 'Adult'
      ELSE 'Old Adult' END  

---How many Passengers are satisfied/neutral by Age Category.
SELECT Age_range,Age_group,Satisfaction
       ,ROUND(COUNT(Satisfaction)*100.0/
	   (SELECT COUNT(Satisfaction) FROM Dano_airline),2) AS Percentage_Count
FROM Dano_airline
GROUP BY Age_range,Age_group,Satisfaction
ORDER BY 4 DESC

---Creating New Column to categorise flight distance into distinct groups
ALTER TABLE Dano_Airline
ADD Distance_category NVARCHAR (50)

UPDATE Dano_Airline
SET Distance_category = 'Short flight'
WHERE Flight_Distance < 800

UPDATE Dano_Airline
SET Distance_category = 'Long flight'
WHERE Flight_Distance >= 800

---How many passengers trvel short distance by class?
 SELECT Class,COUNT(Flight_Distance) AS Short_flight_passengers
            ,ROUND(COUNT(Flight_Distance)*100.0/(SELECT COUNT(Flight_Distance) 
			FROM Dano_airline),2) AS Percentage
 FROM Dano_airline 
 WHERE Distance_category ='short flight'
 GROUP BY Class 

---How many passengers travel long distance by class?
SELECT Class,COUNT(Flight_Distance) AS Long_flight_passengers
            ,ROUND(COUNT(Flight_Distance)*100.0/(SELECT COUNT(Flight_Distance) 
			FROM Dano_airline),2) AS Percentage 
 FROM Dano_airline 
 WHERE Distance_category ='long flight'
 GROUP BY Class

--- Count of passengers by Depature delay less than/equal to 60 minutes and greater than 60 minutes
 WITH CTE1 AS
     (SELECT COUNT(Departure_Delay) AS Min_depaturedelay
 FROM Dano_airline
 WHERE Departure_Delay <='60'),
CTE2 AS
    (SELECT COUNT(Departure_Delay)* 100.0 AS Max_depaturedelay
 FROM Dano_airline
 WHERE Departure_Delay >'60')
SELECT Min_depaturedelay,Max_depaturedelay
FROM CTE1 INNER JOIN CTE2 
ON 1=1 

--- Count of passengers by Arrival delay less than/equal to 60 minutes and greater than 60 minutes
 WITH CTE1 AS 
     (SELECT COUNT(Arrival_Delay) AS Min_arrivaldelay
FROM Dano_airline
 WHERE Arrival_Delay <='60'),
CTE2 AS 
     (SELECT COUNT(Arrival_delay) AS Max_arrivaldelay
FROM Dano_airline
WHERE Arrival_Delay >'60')
SELECT Min_arrivaldelay,Max_arrivaldelay
FROM CTE1 INNER JOIN CTE2 
ON 1=1 

 --Count of departure and arrival time convience by satisfaction
 CREATE VIEW Satisfied AS 
 SELECT TOP 6 Departure_and_Arrival_Time_Convenience
        ,COUNT(Satisfaction) AS Satisfied_customers
 FROM Dano_airline
 WHERE Satisfaction LIKE 'Sat%'
 GROUP BY Departure_and_Arrival_Time_Convenience
 ORDER BY 2 DESC

 CREATE VIEW Nuetral AS 
 SELECT TOP 6 Departure_and_Arrival_Time_Convenience
        ,COUNT(Satisfaction) AS Dissatisfied_customers
 FROM Dano_airline
 WHERE Satisfaction LIKE 'Neutral%'
 GROUP BY Departure_and_Arrival_Time_Convenience
 ORDER BY 2 DESC

 SELECT a.Departure_and_Arrival_Time_Convenience,
        a.Satisfied_customers,b.Dissatisfied_customers
 FROM Satisfied a
 INNER JOIN
 Nuetral b
 ON a.Departure_and_Arrival_Time_Convenience 
    = b.Departure_and_Arrival_Time_Convenience
```

## Recommendation
- Passengers travelling short distances (distance less than 800 miles) prefer to travel via Economy Class whereas passengers travelling Long distance (distance more than or equal to 800 
  miles ) prefer to travel via Business Class due to its convenience. Very Few People fly in Economy Class. At least 70% of passengers flying Economy Class are Neutral or dissatisfied.
- There is a similarity between Arrival delay and Departure delay Satisfaction rate . In conclusion passengers are more dissatisfied with the Departure delay and Arrival delay which is 
 expected.
- Passengers are generally more dissatisfied with the Departure and Arrival Time than satisfied. The average rating is 3.06 within the rating range of 0 to 5. This points out the 
 necessary need for improvement.
- There is a positive correlation between Food and Drink Service and In-Flight Entertainment Service. Food and Drink and Inflight Entertainment are related. Hence,  there is a match 
 between the ratings of both services by passengers. No passenger rated both services with 0, indicating that the overall experience is satisfactory. Improvements in Food and Drink 
 Service will also influence Inflight Entertainment and vice versa.
- The average rating for Ease of Online Booking is 2.76, indicating that most passengers rated it between 2 and 4. Most passengers rated Online Boarding  from 3 to 4, as seen by the 
 average rating  of 3.25.
- There is no service the airline offers that received an overall negative response with majority of the ratings falling between 3  and  5 , and the most reoccurring average for the 
 services is 3. However, there is still need  for improvement. By enhancing services that affects  the general experience of passengers , eg. Seat Comfort, Leg Room Service, Baggage 
 Handling, Cleanliness, Check-in-Service, Online Boarding will contribute to an increase in passengers overall satisfaction.


