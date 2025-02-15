-- Total number of first position finishes for all the drivers
WITH top_results AS(
SELECT * FROM results
WHERE 1 = 1
AND position = '1'
)

SELECT d.forename, d.surname, COUNT(*) AS no_of_wins FROM top_results tr
INNER JOIN drivers d
ON tr.driverId = d.driverId
WHERE 1 = 1
GROUP BY d.forename, d.surname
ORDER BY COUNT(*) DESC;

-- Total number of podium finishes for all the drivers
WITH top_results AS(
SELECT * FROM results
WHERE 1 = 1
AND position IN ('1','2','3')
)

SELECT d.forename, d.surname, COUNT(*) AS podium_finishes FROM top_results tr
INNER JOIN drivers d
ON tr.driverId = d.driverId
WHERE 1 = 1
GROUP BY d.forename, d.surname
ORDER BY COUNT(*) DESC;

-- Total number of points won by drivers until the old points system
WITH top_results AS(
SELECT * FROM results
WHERE 1 = 1
AND position IN ('1','2','3')
),

races_results AS(
SELECT * FROM races
WHERE 1 = 1
AND year between '1960' AND '2009'
)

SELECT forename, surname, SUM(points) AS total_points FROM(
SELECT tr.points,d.forename, d.surname FROM top_results tr
INNER JOIN races_results r
ON tr.raceID = r.raceID
INNER JOIN drivers d
ON tr.driverID = d.driverID
)
GROUP BY forename, surname
ORDER BY SUM(points) DESC;

-- Fastest Lap speed in each circuit ever and the driver
WITH fastestspeed AS(
SELECT raceID, MAX(fAStestLapSpeed) AS fAStestLapSpeed FROM results
WHERE 1 = 1
AND fastestLapSpeed != ''
GROUP BY raceID
--ORDER BY CAST(raceID AS INT)
)

SELECT r.driverID, r.raceID, r.fAStestLapSpeed, d.forename, d.surname, c.name FROM results r
INNER JOIN fAStestspeed f
ON f.fAStestLapSpeed = r.fAStestLapSpeed
INNER JOIN drivers d
ON d.driverID = r.driverID
INNER JOIN races ra
ON r.raceID = ra.raceID
INNER JOIN circuits c
ON c.circuitID = ra.circuitID
ORDER BY CAST(r.raceID AS INT);

-- Driver with most number of retirements
WITH retired_data AS(
SELECT driverID, COUNT(positionText) AS Number_Of_Retirements FROM results
WHERE 1 = 1
AND positionText = 'R'
GROUP BY driverID
--ORDER BY COUNT(positionText) DESC
)

SELECT rd.*,d.forename, d.surname, d.nationality FROM retired_data rd
INNER JOIN drivers d
ON d.driverID = rd.driverID
ORDER BY Number_Of_Retirements DESC;

-- Drivers and the different constructors that they have paired with
WITH results_data AS(
SELECT DISTINCT driverID, constructorID FROM results
)

SELECT d.forename, d.surname, d.nationality AS driver_nationality, c.name, c.nationality AS constructor_nationality FROM drivers d INNER JOIN results_data rd
ON d.driverID = rd.driverID
INNER JOIN constructors c
ON c.constructorID = rd.constructorID
ORDER BY d.forename, d.surname;

-- Drivers with grid position greater than 10 and finishes on the podium
WITH results_data AS(
SELECT grid, position FROM results
WHERE 1 = 1
AND CAST(grid AS INTEGER) >= 11
AND position IN ('1','2','3')
)

SELECT grid, COUNT(*) AS podium_finishes
FROM results_data
GROUP BY grid

Constructors from different nationalities
SELECT nationality, COUNT(*) AS No_Of_constructors
FROM constructors
GROUP BY nationality
ORDER BY COUNT(*) DESC;

-- Drivers from different nationalities
SELECT nationality, COUNT(*) AS No_Of_Drivers
FROM drivers
GROUP BY nationality
ORDER BY COUNT(*) DESC;

-- Driver with most wins at a circuit
WITH results_data AS(
SELECT driverID, raceID FROM results
WHERE 1 = 1
AND position = '1'
),

driver_constructor_vals AS(
SELECT d.forename, d.surname, c.name, COUNT(*) AS No_Of_wins FROM results_data rd
INNER JOIN races r
ON rd.raceID = r.raceID
INNER JOIN drivers d
ON d.driverID = rd.driverID
INNER JOIN circuits c
ON r.circuitID = c.circuitID
GROUP BY d.forename, d.surname, c.name
ORDER BY c.name
),

circuit_wins AS(
SELECT name, MAX(No_Of_wins) AS Highest_wins
FROM driver_constructor_vals
GROUP BY name
)

SELECT dcv.forename, dcv.surname, dcv.name, dcv.No_Of_wins FROM circuit_wins cw
INNER JOIN driver_constructor_vals dcv
ON dcv.name = cw.name
AND dcv.No_Of_wins = cw.Highest_wins;

-- Driver with most podium finishes at a circuit
WITH results_data AS(
SELECT driverID, raceID FROM results
WHERE 1 = 1
AND position IN ('1','2','3')
),

driver_constructor_vals AS(
SELECT d.forename, d.surname, c.name, COUNT(*) AS No_Of_Podium_finishes FROM results_data rd
INNER JOIN races r
ON rd.raceID = r.raceID
INNER JOIN drivers d
ON d.driverID = rd.driverID
INNER JOIN circuits c
ON r.circuitID = c.circuitID
GROUP BY d.forename, d.surname, c.name
ORDER BY c.name
),

circuit_wins AS(
SELECT name, MAX(No_Of_Podium_finishes) AS Highest_wins
FROM driver_constructor_vals
GROUP BY name
)

SELECT dcv.forename, dcv.surname, dcv.name, dcv.No_Of_Podium_finishes FROM circuit_wins cw
INNER JOIN driver_constructor_vals dcv
ON dcv.name = cw.name
AND dcv.No_Of_Podium_finishes = cw.Highest_wins;

-- Constructors with most wins at a circuit
WITH results_data AS(
SELECT constructorID, raceID FROM results
WHERE 1 = 1
AND position = '1'
),

driver_constructor_vals AS(
SELECT d.name AS constructor_name, c.name, COUNT(*) AS No_Of_wins FROM results_data rd
INNER JOIN races r
ON rd.raceID = r.raceID
INNER JOIN constructors d
ON d.constructorID = rd.constructorID
INNER JOIN circuits c
ON r.circuitID = c.circuitID
GROUP BY d.name, c.name
ORDER BY c.name
),

circuit_wins AS(
SELECT name, MAX(No_Of_wins) AS Highest_wins
FROM driver_constructor_vals
GROUP BY name
)

SELECT dcv.constructor_name, dcv.name, dcv.No_Of_wins FROM circuit_wins cw
INNER JOIN driver_constructor_vals dcv
ON dcv.name = cw.name
AND dcv.No_Of_wins = cw.Highest_wins;

-- Constructors with most podium finishes at a circuit
WITH results_data AS(
SELECT constructorID, raceID FROM results
WHERE 1 = 1
AND position IN ('1','2','3')
),

driver_constructor_vals AS(
SELECT d.name AS constructor_name, c.name, COUNT(*) AS No_Of_Podium_finishes FROM results_data rd
INNER JOIN races r
ON rd.raceID = r.raceID
INNER JOIN constructors d
ON d.constructorID = rd.constructorID
INNER JOIN circuits c
ON r.circuitID = c.circuitID
GROUP BY d.name, c.name
ORDER BY c.name
),

circuit_wins AS(
SELECT name, MAX(No_Of_Podium_finishes) AS Highest_wins
FROM driver_constructor_vals
GROUP BY name
)

SELECT dcv.constructor_name, dcv.name, dcv.No_Of_Podium_finishes FROM circuit_wins cw
INNER JOIN driver_constructor_vals dcv
ON dcv.name = cw.name
AND dcv.No_Of_Podium_finishes = cw.Highest_wins;

-- Top constructors each season for past 10 years
WITH top_constructors AS(
SELECT ra.year, c.name, SUM(r.points) AS total_points FROM results r
INNER JOIN races ra
ON r.raceID = ra.raceID
INNER JOIN constructors c
ON r.constructorID = c.constructorID
GROUP BY ra.year, c.name
ORDER BY ra.year DESC, SUM(r.points) DESC
)

SELECT *,tc1.year || '-' || tc1.name AS year_name FROM top_constructors tc1
WHERE tc1.year || '-' || tc1.name IN
(
SELECT tc2.year || '-' || tc2.name
FROM top_constructors tc2
WHERE 1 = 1
AND tc1.year = tc2.year
AND tc1.name = tc2.name
ORDER BY tc2.total_points DESC
)

-- Winners of each season for past 10 years
WITH top_drivers AS(
SELECT ra.year, d.forename, d.surname, SUM(CAST(r.points AS INTEGER)) AS total_points FROM results r
INNER JOIN races ra
ON r.raceID = ra.raceID
INNER JOIN drivers d
ON r.driverID = d.driverID
GROUP BY ra.year, d.forename, d.surname
ORDER BY ra.year DESC, SUM(CAST(r.points AS INTEGER)) DESC
)

SELECT * FROM top_drivers
WHERE 1 = 1
AND CAST(total_points AS INTEGER) > 0;

-- Each race circuit with total number of laps required to complete the race
SELECT DISTINCT c.name, max(CAST(r.laps AS INTEGER)) FROM results r
INNER JOIN races rr
ON r.raceid = rr.raceid
INNER JOIN circuits c
ON c.circuitid = rr.circuitid
WHERE 1 = 1
GROUP BY rr.circuitid
ORDER BY c.name

Drivers with the distribution of qualifications in their careers
WITH driver_qual AS(
SELECT d.forename, d.surname, CASE WHEN q.q3 <> '' THEN 'Q3'
WHEN q.q2 <> '' THEN 'Q2'
ELSE 'Q1' END AS flag FROM qualifyINg q
INNER JOIN drivers d
ON d.driverid = q.driverid
)

SELECT forename, surname, flag, COUNT(*)
FROM driver_qual
GROUP BY forename, surname, flag
ORDER BY forename, surname, COUNT(*) DESC;