# Dano Airline Performance Evaluation Analysis

### Table of Contents
- [Overview](#overview)
- [Data Source](#data-source)
- [Tools used for Analysis](#tools-used-for-analysis)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Modelling](#data-modelling)
- [Findings/Recommendations](#findings-recommendations)

## Overview
The Purpose of this data Analysis Project is to provide insights into the airline passengers satisfaction ratings. Conducting analysisto determine there is a correlation between two or more service ratings and the overall satisfaction level of passengers, finding patterns and trends, visualising the results and making recommendations on areas that require improvement in order to boost customer satisfaction.
 
## Data Source
This is the primary dataset used for this analysis "Airline_data_airline_passenger rating.csv" file [download here](https://docs.google.com/spreadsheets/d/15Kp-2yfQFNRGJPNOkpMwG-OMX8xVZOJ5VL7f35v7sRQ/edit#gid=1647986900)

## Tools Used for Analysis
-  Power Query for Data Cleaning
-  SQL Server for Exploratory Data Analysis and Data Modelling
-  Power BI for Data Visualization and Reports

 ## Data Cleaning
 -  Data Loading and inspecting for missing values and errors
    Arrival delay column has about 393 Null. Median was used to correct this errors
  
## Exploratory Data Analysis
EDA involved exploring the data to answer key questions;
- How many passengers are satisfied/dissatisfied when depature delay and arrival delay is less than or equal to 60 minutes and more than 60 minutes?
- Is there a correlation between two or more services?
- flight distance by satisfaction less than 800 miles and more than or equal to 800 miles
- How many passengers are Satisfied/dissatisfied with depature and arrival time convenience?
- Whats the satisfaction rate by age category?
- Whats the average rating of each service?
- Whats the overall experience of Passengers?
- Satisfaction rate by type of travel

## Data Modelling
```sql
SELECT * FROM Dano_Airline

---Passenger overall experience by satisfaction
SELECT Satisfaction,COUNT(Satisfaction) AS Total_satisfaction
                   ,COUNT(Satisfaction )*100.0
				   /(SELECT COUNT(Satisfaction)FROM Dano_Airline) 
				   AS Percentage 
FROM Dano_Airline
GROUP BY Satisfaction

---Total Count of Satisfied /Dissatisfied Passengers by Gender 
 SELECT Gender,Satisfaction
             ,COUNT(Gender) AS Gender_count
              ,ROUND(COUNT(Gender)*100.0
			  /(SELECT COUNT(Gender) FROM Dano_Airline),2) AS Percentage 
 FROM Dano_Airline
 GROUP BY Gender,Satisfaction
 ORDER BY 3 DESC

 ---Total Count of Satisfied /Dissatisfied Passengers by TypeofTravel 
 SELECT Satisfaction
       ,Type_of_Travel,COUNT(Type_of_travel) AS Typecount
                      ,COUNT(Type_of_travel)*100
					  /(SELECT COUNT(Type_of_travel)FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY Satisfaction,Type_of_Travel
 
 ---How many Passenger are in Business Class? 
 SELECT class,COUNT(class) AS classcount
             ,COUNT(Class)*100/(SELECT COUNT(Class)
	         FROM Dano_Airline) AS Percentage 
 FROM Dano_Airline
 GROUP BY class
 ORDER BY 2 DESC

--- How many Passengers  are satisfied/neutral in each Age Category 
SELECT Age_category,Satisfaction
      ,COUNT(Satisfaction) AS Satisfaction_Count
      ,ROUND(COUNT(Satisfaction)*100.0/
	  (SELECT COUNT(Satisfaction) FROM Dano_Airline),2) AS Percentage 
FROM 
  (SELECT Age,Satisfaction,
       CASE WHEN Age BETWEEN 7 AND 12 THEN 'Adolescent'
       WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
       WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
       WHEN Age BETWEEN 36 AND 55 THEN 'Adult'
       ELSE 'Old Adult' END  AS Age_Category 
       FROM Dano_Airline)
Dano_Airline
GROUP BY  Age_category,Satisfaction
ORDER BY  1,2 DESC


 --count of depature delay and arrival delay by satisfaction,and having  <=60 minutes and >60 minutes 
 --Depature_delay less than/equal to 60 minutes 
 SELECT Satisfaction
       ,COUNT(Satisfaction) AS Mindepaturedelay_count
 FROM Dano_Airline
 WHERE Departure_Delay <= '60' AND Satisfaction ='satisfied'
 GROUP BY Satisfaction
  UNION 
 SELECT Satisfaction
       ,COUNT(Satisfaction) AS Mindepaturedelay_count
 FROM Dano_Airline
 WHERE Departure_Delay <='60' AND Satisfaction LIKE 'neutral%'
 GROUP BY Satisfaction

 ---Depature delay more than to 60 minutes 
SELECT Satisfaction
       ,COUNT(Satisfaction) AS MaxDepaturdelay_count
FROM Dano_Airline
WHERE Departure_Delay >'60' AND Satisfaction ='satisfied'
GROUP BY Satisfaction
   UNION 
SELECT Satisfaction
       ,COUNT(Satisfaction) AS MaxDepaturdelay_count
FROM Dano_Airline
WHERE Departure_Delay >'60' AND Satisfaction LIKE 'neutral%'
GROUP BY Satisfaction

----Arrival delay less than/equal 60 minutes 
SELECT Satisfaction
       ,COUNT(Satisfaction) AS minarrivaldelay_count
FROM Dano_Airline
WHERE Arrival_Delay <='60' AND Satisfaction ='satisfied'
GROUP BY Satisfaction
  UNION 
SELECT Satisfaction
       ,COUNT(Satisfaction) AS minarrivaldelay_count
FROM Dano_Airline
WHERE Arrival_Delay <='60' AND Satisfaction LIKE 'Neutral%'
GROUP BY Satisfaction

-----Arrival delay more than 60 minutes 
SELECT Satisfaction
       ,COUNT(Satisfaction) AS MaxArrivaldelay_count
FROM Dano_Airline
WHERE Arrival_Delay >'60' AND Satisfaction ='satisfied'
GROUP BY Satisfaction
  UNION 
SELECT Satisfaction
       ,COUNT(Satisfaction) AS MaxArrivaldelay_count
FROM Dano_Airline
WHERE Arrival_Delay >'60' AND Satisfaction LIKE 'Neutral%'
GROUP BY Satisfaction
  
 
 ---passengers satisfaction rate by flightdistance below 800 miles and above or equal to 800 miles 
 WITH Flight_distance1 AS (
 SELECT Class,COUNT(Flight_Distance) AS Short_flight
      ,ROUND(COUNT(Flight_Distance)*100.0/(SELECT COUNT(Flight_Distance) 
	FROM Dano_Airline),2) AS Percentage
 FROM Dano_Airline 
 WHERE Flight_Distance < 800
 GROUP BY Class),
 Flight_distance2 AS(
SELECT Class,COUNT(Flight_Distance) AS Long_flight
       ,ROUND(COUNT(Flight_Distance)*100.0/(SELECT COUNT(Flight_Distance) 
		FROM Dano_Airline),2) AS Percentage 
 FROM Dano_Airline 
 WHERE Flight_Distance >= 800
 GROUP BY Class)
SELECT S.Class,Short_Flight,S.Percentage,Long_Flight,L.Percentage
FROM Flight_distance1 S
INNER JOIN Flight_distance2 L
ON  S.Class = L.Class

 -- How many Passengers are Satisfied/Dissatisfied with departure and arrival time convenience 
 WITH  Satisfied AS (
 SELECT Departure_and_Arrival_Time_Convenience
       ,COUNT(Satisfaction) AS Satisfied_Passengers
 FROM Dano_Airline
 WHERE Satisfaction LIKE 'Sat%'
 GROUP BY Departure_and_Arrival_Time_Convenience),
 Neutral AS (
 SELECT Departure_and_Arrival_Time_Convenience
        ,COUNT(Satisfaction) AS Dissatisfied_Passengers
 FROM Dano_Airline
 WHERE Satisfaction LIKE 'Neutral%'
 GROUP BY Departure_and_Arrival_Time_Convenience)

 SELECT S.Departure_and_Arrival_Time_Convenience
       ,Satisfied_Passengers,Dissatisfied_Passengers
 FROM Satisfied S INNER JOIN Neutral N
 ON S.Departure_and_Arrival_Time_Convenience 
  = N.Departure_and_Arrival_Time_Convenience
ORDER BY 1 ASC

SELECT Departure_and_Arrival_Time_Convenience,COUNT(Departure_and_Arrival_Time_Convenience ) 
FROM Dano_Airline 
GROUP BY Departure_and_Arrival_Time_Convenience  
ORDER BY 2 DESC

 --check in service and baggage handling 
 SELECT Check_in_Service
        ,COUNT( Check_in_Service) AS Passenger_count
        ,COUNT( Check_in_Service)*100.0
		/(SELECT COUNT ( Check_in_Service) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY  Check_in_Service
 ORDER BY 2 DESC

 SELECT Baggage_Handling
        ,COUNT(Baggage_Handling) AS Passenger_Count
         ,COUNT(Baggage_Handling)*100.0
         /(SELECT COUNT (Baggage_Handling) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY Baggage_Handling
 ORDER BY 2 DESC

---ease of online booking VS online boarding 
WITH CTE1 AS 
(SELECT Ease_of_Online_Booking,COUNT(ID) AS Booking_Passenger_Count
 FROM Dano_Airline
 GROUP BY Ease_of_Online_Booking),
 CTE2 AS 
 (SELECT Online_Boarding,COUNT(ID) AS Boarding_Passenger_Count
 FROM Dano_Airline
 GROUP BY Online_Boarding)
SELECT Ease_of_Online_Booking,Booking_Passenger_Count
      ,Boarding_Passenger_Count
FROM CTE1 E INNER JOIN CTE2 O
ON Ease_of_Online_Booking=Online_Boarding

 --on board service and cleanliness 
 SELECT On_board_Service
        ,COUNT(On_board_Service) AS Passenger_count
        ,COUNT(On_board_Service)*100.0
		/(SELECT COUNT (On_board_Service) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY On_board_Service
 ORDER BY 2 DESC

 SELECT Cleanliness
        ,COUNT(Cleanliness) AS Passenger_Count
         ,COUNT(Cleanliness)*100.0
         /(SELECT COUNT (Cleanliness) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY Cleanliness
 ORDER BY 2 DESC

--- Is there a Correlation between food & drink and inflight entertainment ? 
 WITH CTE1 AS (SELECT Food_and_Drink
           ,COUNT(ID) AS Food_and_Drink_Count
 FROM Dano_Airline
 GROUP BY Food_and_Drink),
 CTE2 AS (SELECT In_flight_Entertainment
         ,COUNT(ID) AS In_flight_Entertainment_Count        
FROM Dano_Airline
GROUP BY In_flight_Entertainment)
SELECT Food_and_Drink AS Rating,Food_and_Drink_Count
       ,In_flight_Entertainment_Count
FROM CTE1  INNER JOIN CTE2 
 ON  Food_and_Drink = In_flight_Entertainment
 ORDER BY 1 ASC


 ---inflight service and inflight wifi service 
 SELECT In_flight_service
        ,COUNT(In_flight_Service) AS Passenger_count
        ,COUNT(In_flight_Service)*100.0
		/(SELECT COUNT (In_flight_Service) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY In_flight_Service
 ORDER BY 2 DESC
 SELECT In_flight_wifi_service
        ,COUNT(In_flight_wifi_service) AS Passenger_count
         ,COUNT(In_flight_wifi_service)*100.0
         /(SELECT COUNT (In_flight_wifi_service) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY In_flight_Wifi_Service
 ORDER BY 2 DESC


 -- IS there a relationship betweeen seat comfort and leg room service by rating?
 --seat comfort
 SELECT Seat_Comfort
        ,COUNT(Seat_Comfort) AS Passenger_count
        ,COUNT(Seat_Comfort)*100.0
		/(SELECT COUNT (Seat_Comfort) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY Seat_Comfort
 ORDER BY 2 DESC
 --leg room service
 SELECT Leg_Room_Service
        ,COUNT(Leg_Room_Service) AS Passenger_count
         ,COUNT(Leg_Room_Service)*100.0
         /(SELECT COUNT (Leg_Room_Service) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY Leg_Room_Service
 ORDER BY 2 DESC

 --- gate location 
 SELECT Gate_Location
        ,COUNT( Gate_Location) AS Passenger_count
         ,COUNT( Gate_Location)*100.0
         /(SELECT COUNT ( Gate_Location) FROM Dano_Airline) AS Percentage
 FROM Dano_Airline
 GROUP BY  Gate_Location
 ORDER BY 2 DESC

---Whats the average rating of each service?
 SELECT AVG(CAST(In_flight_Entertainment AS DECIMAL))
       ,AVG(CAST(In_flight_Wifi_Service AS DECIMAL))
	   ,AVG(CAST(In_flight_Service AS DECIMAL))
	   ,AVG(CAST(On_board_Service AS DECIMAL))
	   ,AVG(CAST(Online_Boarding AS DECIMAL))
       ,AVG(CAST(Ease_of_Online_Booking AS DECIMAL))
	   ,AVG(CAST(Leg_Room_Service AS DECIMAL))
	   ,AVG(CAST(Seat_Comfort AS DECIMAL))
	   ,AVG(CAST(Baggage_Handling AS DECIMAL))
       ,AVG(CAST(Departure_and_Arrival_Time_Convenience AS DECIMAL))
	   ,AVG(CAST(Food_and_Drink AS DECIMAL))
	   ,AVG(CAST(In_flight_Entertainment AS DECIMAL))
	   ,AVG(CAST(Gate_Location AS DECIMAL))
	   ,AVG(CAST(Cleanliness AS DECIMAL))
	   ,AVG(CAST(Check_in_Service AS DECIMAL))
 FROM Dano_Airline
```

## Findings/Recomendations
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


[Dano Airline Dashboard.pdf](https://github.com/BukolaOrire/Airline_Satisfaction_Rating/files/14406713/Dano.Airline.Dashboard.pdf)
line dashboard.pdf)
  
