//Batch inserts by 1000 at a time. It does not make a difference for this project, but it is a good practice for larger projects.
USING PERIODIC COMMIT 1000
//Loading the CSV with headers
LOAD CSV WITH HEADERS FROM "file:///data.csv" AS line
//split the date delimited by ' ' and pass down the line variable
WITH SPLIT(line.Date, ' ') as date, line
//assign alliases to array index 1 which represents day, 2 representing month and 3 year
WITH date[1] as day, date[2] as monthName, date[3] as year,
//substring the day name which is included in parenthesis: start from the second character to leave the parenthesis out and end on the second from the end character to leave out the second parenthesis
//substring the week number the same way as the day name was handled
SUBSTRING(date[0], 1, size(date[0]) - 2) as dayName, SUBSTRING(date[4], 1, size(date[4]) - 2)  as week, line
//collecting all relevant match data in a list with the date now broken into manageable pieces
WITH collect([day, monthName, year, dayName, week, line.Round, line.`Team 1`, line.FT, line.HT, line.`Team 2`]) as data, line
//turn list back into individual rows
UNWIND data as allData
//and create an array with all month names (three letters)
WITH allData, ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"] as allMonthNames

//merging match nodes with (if nodes already exist they will not be created again):
//day number to integer
//month converted from month name to integer for easier manipulation
//year remains as string
//dayName remains as is
//week number to integer
//round number to integer
//the name of the home team
//FT - full time score
//HT - half time score
//awayTeam name
MERGE
(m:Match{day: toInteger(allData[0]),
  month: toInteger([i IN RANGE(0, SIZE(allMonthNames)-1) WHERE allMonthNames[i] = allData[1]][0] + 1),
  year: allData[2],
  dayName: allData[3],
  week: toInteger(allData[4]),
  round: toInteger(allData[5]),
  homeTeam: allData[6],
  FT: allData[7],
  HT: allData[8],
  awayTeam: allData[9] }) WITH allData as allData, m as m
  //also merging the two team nodes relating to this match (if nodes already exist they will not be created again)
MERGE (t1:Team{name: allData[6]})
MERGE (t2:Team{name: allData[9]})

//score format 5-4
//Splitting on - delimiter

//FT and HT first element home team
//FT and HT second element away team
WITH toInteger(SPLIT(allData[7], '-')[0]) AS goalsScoredFTHome,
 toInteger(SPLIT(allData[8], '-')[0]) AS goalsScoredHTHome,
 toInteger(SPLIT(allData[7], '-')[1]) AS goalsScoredFTAway,
 toInteger(SPLIT(allData[8], '-')[1]) AS goalsScoredHTAway, m AS m , t1 AS t1, t2 AS t2
 //Next relationships between the nodes are created and type is determined (WON, LOST, DRAW), based on the score variables that were processed earlier.
 //Goals scored for FT and HT are stored respectively in the relationship of each team with the match as shown in the design.
 FOREACH
 (allData in CASE WHEN (goalsScoredFTHome > goalsScoredFTAway) THEN [1] ELSE [] END |
  merge (t1)-[r1:WON{ goalsScoredFT: goalsScoredFTHome, goalsScoredHT: goalsScoredHTHome}]->(m)<-[r2:LOST{goalsScoredFT: goalsScoredFTAway, goalsScoredHT: goalsScoredHTAway}]-(t2)
 )
 FOREACH
 (allData in CASE WHEN (goalsScoredFTHome = goalsScoredFTAway) THEN [1] ELSE [] END |
  merge (t1)-[r1:DRAW{ goalsScoredFT: goalsScoredFTHome, goalsScoredHT: goalsScoredHTHome}]->(m)<-[r2:DRAW{goalsScoredFT: goalsScoredFTAway, goalsScoredHT: goalsScoredHTAway}]-(t2)
 )
 FOREACH
 (allData in CASE WHEN (goalsScoredFTHome < goalsScoredFTAway) THEN [1] ELSE [] END |
  merge (t1)-[r1:LOST{ goalsScoredFT: goalsScoredFTHome, goalsScoredHT: goalsScoredHTHome}]->(m)<-[r2:WON{goalsScoredFT: goalsScoredFTAway, goalsScoredHT: goalsScoredHTAway}]-(t2)
 )
