--1. Create a table named ‘matches’ with appropriate data types for columns
	
CREATE TABLE Deliveries (
Id int,
Inning int,
Over_number int,
Ball int,
Batsman varchar,
Non_striker varchar,
Bowler varchar,
Batsman_runs int,
Extra_runs int,
Total_runs int,
Is_wicket varchar,
Dismissal_kind varchar,
Player_dismissed varchar,
Fielder varchar,
extras_type varchar,
batting_team varchar,
bowling_team varchar,


constraint fk_matches
foreign key (id)
references matches (id)
)

--2. Create a table named ‘matches’ with appropriate data types for columns

CREATE TABLE Matches (
Id int primary key,
City varchar,
date Date,
Player_of_match varchar,
Venue varchar,
neutral_venue varchar,
Team1 varchar,
Team2 varchar,
Toss_winner varchar,
Toss_decision varchar,
Winner varchar,
result varchar,
result_margin int,
eliminator varchar,
Method varchar,
Umpire1 Varchar,
Umpire2 varchar)

copy matches from 'C:\Program Files\PostgreSQL\15\installer\IPLMatches+IPLBall\IPL_matches.csv' csv header

copy Deliveries from 'C:\Program Files\PostgreSQL\15\installer\IPLMatches+IPLBall\IPL_Ball.csv' csv header

--5. Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball 

SELECT id, inning, over_number, ball
FROM Deliveries
ORDER BY id, inning, over_number, ball
LIMIT 20

--6. Select the top 20 rows of the matches table.

SELECT * FROM matches
LIMIT 20

--7. Fetch data of all the matches played on 2nd May 2013 from the matches table.

SELECT *
FROM matches
WHERE date = '2013-05-02'

--8. Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.

SELECT *
FROM matches
WHERE result = 'runs' AND result_margin > 100

--9. Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.

SELECT * 
FROM matches
WHERE result = 'tie'
ORDER BY date DESC

--10. Get the count of cities that have hosted an IPL match.

SELECT COUNT(distinct(city))
FROM matches

-- 11. Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number).

CREATE TABLE deliveries_02 as
SELECT *,
CASE WHEN total_runs >= 4 THEN 'boundary'
WHEN total_runs = 0 THEN 'dot'
ELSE 'other' 
END AS ball_result
FROM Deliveries


--12. Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.

SELECT ball_result, COUNT(*)
FROM deliveries_02
WHERE ball_result IN('boundary', 'dot')
GROUP BY ball_result

--13. Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled.

SELECT COUNT(*) as total_dots, bowling_team
FROM deliveries_02
WHERE ball_result ='dot'
GROUP BY bowling_team
ORDER BY total_dots DESC

--14. Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored.

SELECT COUNT(*) as total_boundary, bowling_team
FROM deliveries_02
WHERE ball_result ='boundary'
GROUP BY bowling_team
ORDER BY total_boundary DESC

--15. Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA.

SELECT COUNT(*), dismissal_kind
FROM Deliveries
WHERE dismissal_kind != 'NA'
GROUP BY dismissal_kind
ORDER BY COUNT desc

--16. Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table.

SELECT SUM(extra_runs) as Sum, bowler
FROM deliveries
GROUP BY extra_runs, bowler
ORDER BY Sum DESC
LIMIT 5

--17. Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches

CREATE TABLE deliveries_v03 as
SELECT d.*,
m.venue, m.date
FROM deliveries_02 d
JOIN matches m
ON m.id = d.id 

--18. Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.

SELECT SUM(total_runs) as runs_made, venue
FROM deliveries_v03
GROUP BY total_runs, venue
ORDER BY runs_made DESC

--19. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.

SELECT SUM(total_runs) as runs_made, date_part('year',date) as ipl_year
FROM deliveries_v03
WHERE venue = 'Eden Gardens'
GROUP BY total_runs, date
ORDER BY runs_made DESC

--20. Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03)

CREATE TABLE deliveries_v04 as
SELECT concat(id,'-',inning,'-',over_number,'-',ball) as ball_id, *
FROM deliveries_v03

--21. Compare the total count of rows and total count of distinct ball_id in deliveries_v04.

SELECT COUNT(*) as row_count, COUNT(DISTINCT(ball_id)) as ball_count
FROM deliveries_v04

--22. Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id.

CREATE TABLE deliveries_v05 as
SELECT *, row_number() over (partition by ball_id) as r_num
FROM deliveries_v04

--23. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating.

 select * from deliveries_v05 WHERE r_num=2

--24. Use subqueries to fetch data of all the ball_id which are repeating.

SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2)



