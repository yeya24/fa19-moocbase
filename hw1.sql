DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era) FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE namefirst ~ '.* .*'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*) FROM people GROUP BY birthyear ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*) FROM people GROUP BY birthyear HAVING AVG(height) > 70  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT  P.namefirst, P.namelast, P.playerid, H.yearid  FROM people AS P,  halloffame AS H WHERE P.playerid = H.playerid and H.inducted = 'Y' ORDER BY  H.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT  P.namefirst, P.namelast, P.playerid, S.schoolid, H.yearid FROM halloffame AS H, people AS P, schools AS S, collegeplaying AS C WHERE H.inducted = 'Y' and  P.playerid = H.playerid and P.playerid = C.playerid and S.schoolid = C.schoolid and S.schoolstate = 'CA' ORDER BY H.yearid DESC, schoolid, playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT P.playerid, P.namefirst, P.namelast, C.schoolid FROM halloffame AS H, people AS P left outer join collegeplaying AS C on P.playerid=C.playerid WHERE H.inducted='Y' and P.playerid=H.playerid ORDER BY P.playerid DESC, C.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT P.playerid, P.namefirst, P.namelast, B.yearid, (B.h+B.h2b+B.h3b*2+B.hr*3)/cast(B.ab AS real) AS slg FROM people AS P, batting AS B where P.playerid = B.playerid and B.ab != 0 and B.ab > 50 ORDER BY slg DESC, yearid, playerid LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT P.playerid, P.namefirst, P.namelast, (SUM(B.h)+SUM(B.h2b)+SUM(B.h3b)*2+SUM(B.hr)*3)/cast(SUM(B.ab) AS real) AS lslg  FROM people AS P, batting AS B WHERE P.playerid = B.playerid GROUP BY P.playerid HAVING SUM(B.ab) > 50 ORDER BY lslg DESC, playerid ASC LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT P.namefirst, P.namelast, (SUM(B.h)+SUM(B.h2b)+SUM(B.h3b)*2+SUM(B.hr)*3)/cast(SUM(B.ab) AS real) AS lslg  FROM people AS P, batting AS B WHERE P.playerid = B.playerid GROUP BY P.playerid HAVING SUM(B.ab) > 50 and (SUM(B.h)+SUM(B.h2b)+SUM(B.h3b)*2+SUM(B.hr)*3)/cast(SUM(B.ab) AS real)  > (SELECT (SUM(h)+SUM(h2b)+SUM(h3b)*2+SUM(hr)*3)/cast(SUM(ab) AS real) FROM  batting WHERE playerid = 'mayswi01' GROUP BY playerid)
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), stddev(salary) FROM salaries GROUP BY yearid ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH X AS (SELECT MIN(salary), MAX(salary) FROM salaries WHERE yearid=2016), Y AS (SELECT i AS binid, i*(X.max-X.min)/10.0 + X.min AS low, (i+1)*(X.max-X.min)/10.0 + X.min AS high FROM generate_series(0,9) AS i, X)
  SELECT binid, low, high, COUNT(*) FROM Y INNER JOIN salaries AS S on s.salary >= Y.low AND (s.salary < Y.high OR binid = 9 AND s.salary <= Y.high) AND yearid=2016 GROUP BY binid, low, high ORDER BY binid  
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH X AS (SELECT MIN(salary), MAX(salary), AVG(salary), yearid FROM salaries GROUP BY yearid)
  SELECT m2.yearid, m2.min - m1.min AS mindiff, m2.max - m1.max AS maxdiff, m2.avg - m1.avg AS avgdiff FROM X AS m1 inner join X AS m2 ON m2.yearid = m1.yearid + 1 ORDER BY yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT P.playerid, P.namefirst, P.namelast, S.salary, S.yearid FROM people AS P, salaries AS S WHERE P.playerid=S.playerid and (yearid=2000 or yearid=2001)  and S.salary >=  (SELECT MAX(salary) FROM salaries WHERE yearid=2000 or yearid=2001 and yearid=S.yearid)
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  WITH X AS (SELECT A.teamid, MIN(S.salary), MAX(S.salary) FROM salaries AS S, allstarfull AS A WHERE A.playerid=S.playerid and A.yearid=S.yearid and S.yearid=2016 GROUP BY A.teamid ORDER BY A.teamid)
  SELECT X.teamid AS team, X.max-X.min AS diffavg  FROM X ORDER BY teamid
;

