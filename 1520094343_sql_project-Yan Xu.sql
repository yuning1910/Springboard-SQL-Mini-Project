/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name
FROM `Facilities` 
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(facid) AS Number_facilities_no_fee_member
FROM `Facilities` 
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid AS Facility_ID, name AS Facility_Name, membercost AS Member_Cost, monthlymaintenance AS Monthly_Maintenance
FROM `Facilities` 
WHERE membercost < 0.2* monthlymaintenance AND membercost > 0

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
FROM `Facilities` 
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name AS Facility_Name, monthlymaintenance AS Monthly_Maintenance,
       CASE WHEN monthlymaintenance <= 100 THEN 'Cheap'
            ELSE 'Expensive' END AS Cheap_Or_Expensive
FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname AS First_Name, surname AS Last_Name, joindate
FROM `Members` 
WHERE joindate = (SELECT MAX(joindate)
                  FROM  `Members`)
                  

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT (CONCAT(M1.firstname, ' ', M1.surname)) AS Member_Name, F1.name AS Court_Name
FROM `Facilities` F1, `Members` M1, `Bookings` B1
WHERE  F1.facid = B1.facid AND B1.memid = M1.memid AND F1.name LIKE 'Tennis%'
ORDER BY Member_Name
    

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT F1.name AS facility_name, CONCAT( M1.firstname,  ' ', M1.surname ) AS member_name, 
CASE WHEN B1.memid =0
THEN F1.guestcost * B1.slots
ELSE F1.membercost * B1.slots
END AS total_cost
FROM Bookings B1
INNER JOIN Facilities F1 ON B1.facid = F1.facid
AND B1.starttime LIKE  '2012-09-14%'
AND (((B1.memid =0) AND (F1.guestcost * B1.slots >30))
OR ((B1.memid !=0) AND (F1.membercost * B1.slots >30)))
INNER JOIN Members M1 ON B1.memid = M1.memid
ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT F1.name AS facility_name, CONCAT( M1.firstname,  ' ', M1.surname ) AS member_name, 
CASE WHEN B1.memid =0
THEN F1.guestcost * B1.slots
ELSE F1.membercost * B1.slots
END AS total_cost
FROM Bookings B1
INNER JOIN Facilities F1 ON B1.facid = F1.facid
AND B1.starttime IN (SELECT starttime FROM B1 WHERE starttime LIKE  '2012-09-14%')
AND (((B1.memid =0) AND (F1.guestcost * B1.slots >30))
OR ((B1.memid !=0) AND (F1.membercost * B1.slots >30)))
INNER JOIN Members M1 ON B1.memid = M1.memid
ORDER BY total_cost DESC
         
 

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT * 
FROM (
SELECT sub.facility_name, SUM( sub.total_cost ) AS total_revenue
FROM (
SELECT F1.name AS facility_name, 
CASE WHEN B1.memid =0
THEN F1.guestcost * B1.slots
ELSE F1.membercost * B1.slots
END AS total_cost
FROM Bookings B1
INNER JOIN Facilities F1 ON B1.facid = F1.facid
INNER JOIN Members M1 ON B1.memid = M1.memid
)sub
GROUP BY sub.facility_name
)sub2
WHERE sub2.total_revenue <1000