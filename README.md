# Dano Airline Passengers Satisfaction Rating Analysis

### Table of Contents
- [Project Overview](#project-overview)
- [Data Source](#data-source)
- [Tools used for Analysis](#tools-used-for-analysis)
- [Data Cleaning](#data-cleaning)
- [Problem Statement](#problem-statement)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Visualization](data-visaualization)
- [Findings](#findings)
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
- How many passengers are satisfied and dissatisfied when depature delay and arrival delay is less than or equal to 60 minutes and more than 60 minutes?
- Is there a correlation between any of the services rendered by the airline?
- flight distance by satisfaction less than 800 miles and more than or equal to 800 miles
- How many passengers are satisfied and dissatisfied with depature and arrival time convenience?
- What is the passengers count by age group?
- Whats the average rating of each service?


## Exploratory Data Analysis
#### passengers satisfaction rate 
```sql
SELECT Satisfaction,COUNT(Satisfaction)*100.0/(SELECT COUNT(Satisafaction) FROM Dano_airline)
FROM Dano_airline
GROUP BY Satisfaction
```
![satisfaction_rate](https://github.com/BukolaOrire/Airline_Satisfaction_Rating/assets/161165047/12e20c94-4fc6-425a-ae50-848459db7e7c)

#### Count of passengers by Depature delay less than/equal to 60 minutes and greater than 60 minutes
```sql
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
```
![depature_count](https://github.com/BukolaOrire/Airline_Satisfaction_Rating/assets/161165047/c7dad1ce-44de-4890-b4c9-d3a4baefca54)

#### Count of passengers by Arrival delay less than/equal to 60 minutes and greater than 60 minutes
```sql
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
```
![arrival_count](https://github.com/BukolaOrire/Airline_Satisfaction_Rating/assets/161165047/4945aee9-0e1d-45a3-917a-0809149e0455)



## Data Visualization
![dano_airline](https://github.com/BukolaOrire/Airline_Satisfaction_Rating/assets/161165047/3515c8d2-f7dc-4df4-9ed2-b770a26b46fb)


## Findings
- More passengers travel for business compared to personal, and more than 80% of passengers in business type of travel are satisfied with the overall experience while only 7% personal are satisfied.
- Most passengers are returning customers and only few are first-time passengers.
- 60% of Passengers travelling short distances (distance less than 800 miles) travel for personal reasons whereas 77% of passengers travelling Long distance (distance greater than or equal to 800 miles ) travel for Business, this may be due to its convenience.
- Business class has more customer patronage compared to other class of travel. Very Few People travel via economy class and 65% of passengers traveling via economy class are the most Neutral or dissatisfied.
- There are similarities between Arrival delay and Departure delay satisfaction count. High number of passengers are satisfied with the Departure delay and Arrival delay less than or equal to 60 minutes compared to delay more than 60 minutes which is expected.
- High number of passengers rated departure and arrival time convenience between 4 and 5, suggesting that most passengers may have been satisfied with this service.
- There is a positive correlation between Food and Drink Service and In-flight entertainment service. food and drink and inflight entertainment are related. Hence, there is a match between the ratings of both services. No passenger rated both services with 0, indicating that the overall experience is satisfactory.
- The average rating for Ease of Online Booking is 2.76, indicating that most passengers rated from 2 to 3. Most passengers rated Online Boarding from 3 to 4, as seen by the 
 average rating  of 3.25.
- There is no service the airline offers that received an overall negative response with majority of the ratings falling between 3 and 5, and the most reoccurring average for the services is 3. However, there is still need for improvement.

## Recommendation
- By enhancing services that influence the general experience of passengers eg. seat comfort, leg room service, Baggage handling, Cleaniness, Check-in-service, Online boarding etc will contribute to improving customers overall satisfaction and also attract new customers.
- Improvement in one of two services that are positively correlated such as food and drink & inflight entertainment, seat comfort & leg room service, ease of online booking & online boarding may influence the other.
- There is a specific need for improvement in the overal services offered for passengers in economy class as they are the most dissatisfied class.
- Introducing FAQS and updating its user experience will help provide relevant insights on frequent customers questions and concern, and assit management to understand their customers better which may help improve success rate of the buisness. 
  
