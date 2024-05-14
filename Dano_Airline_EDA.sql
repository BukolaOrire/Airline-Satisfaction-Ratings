```sql
SELECT * FROM Dano_airline
```
---Passengers count by Type of travel
SELECT Type_of_Travel,COUNT(Type_of_travel) AS Typecount
 FROM Dano_airline
 GROUP BY Satisfaction,Type_of_Travel

-- Passenger count of class 
 SELECT class,COUNT(class) AS classcount
 FROM Dano_airline
 GROUP BY class
 
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
