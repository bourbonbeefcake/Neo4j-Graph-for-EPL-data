
//Get the total number of matches
MATCH (m:Match) RETURN count(m) AS numberOfMatches

//Display details of all matches involved “Manchester United FC”.
MATCH (m:Match)<-[r]-(t:Team{name: "Manchester United FC"}) RETURN properties(m)
//OR
MATCH (m:Match)<-[r]-(t:Team{name: "Manchester United FC"}) RETURN m


//Display the team with the most “win” in January.
//The first query is only to get the maximum value of the wins
MATCH (n:Team)-[r:WON]->(m:Match{month: 1})
//Counting wins
WITH n, COUNT(r) as count
//Keeping the maximum value
WITH MAX(count) as max
//Querrying again
MATCH (n:Team)-[r:WON]->(m:Match{month: 1})
WITH n, COUNT(r) as count, max
//Keeping only the results whose win count is equal with the max
WHERE count = max
RETURN n.name as `Team Name`, count as `Goals On January`



//FIFTH
//Show top five teams with the best scoring power.
//Match all matches and teams
MATCH (t:Team)-[r]->(m:Match)
//return the name of the team and the sum total of each team's scoring power
//the total scoring power is a sum of the goals scored in FT which resides in the relationships
RETURN t.name AS `Team Name`, sum(r.goalsScoredFT) AS allGoals
//order from higher to lower and limit the results to 5
ORDER BY allGoals DESC LIMIT 5




//SIXTH
//Show top five teams with worst defending.
//Match the matches and both teams at the same time connected to that match
MATCH (t1:Team)-[r1]->(m:Match)<-[r2]-(t2:Team)
//Since we want to display the worst defending aka the teams who took most goals
//we need to sum the goals of the t2 which reside in r2
//but we will show the name of the t1
RETURN t1.name AS `Team Name`, sum(r2.goalsScoredFT) AS allGoals
ORDER BY allGoals DESC LIMIT 5

//SEVENTH
//Match all teams and matches (one team at a time), and get only the wins and draws
MATCH
(t:Team)-[r:WON|DRAW]->(m:Match)
//collect the types of the gathered relationships in an array
//and pass down the name of the team as well
WITH collect(type(r)) as matchResult, t.name as teamName
//loop through the relationship type array
WITH reduce(data = {points: 0, teamName: teamName}, rel IN matchResult |
  //when a win is found
  CASE WHEN rel = "WON"
  THEN {
    //increase the "points" variable by 3
    points: data.points + 3
  }
  ELSE {
    //else (if draw is found) increase the "points" variable by 1
    points: data.points + 1
  }
  END

  ) AS result, teamName
  //make the array a list
UNWIND result.points as points
RETURN points, teamName
ORDER BY points DESC


// EIGHTH
//Show op five teams with best half time result.
MATCH
//get all matches and the two teams that played
(t:Team)-[r]->(m:Match)<-[r2]-(t2:Team)
//collect the HT goals total from both the teams in this much as well as the team name
//pipe that on the next query with WITH
WITH collect([r.goalsScoredHT, r2.goalsScoredHT]) as halfTimeScores, t.name as teamName
//use reduce to count points
WITH reduce(data = {points: 0, teamName: teamName}, rel IN halfTimeScores |
  //whenever the first team's score is bigger than the second's
  CASE WHEN rel[0] > rel[1]
  THEN {
    //add 3 points for the first team
    points: data.points + 3
  }
  //when equal so draw add 1 to the first team
  WHEN rel[0] = rel[1]
  THEN {
    points: data.points + 1
  }
  //if lost add none
  ELSE {
    points: data.points + 0
  }
  END
//return the result points and the team names
  ) AS result, teamName
  //unwind the list to rows
UNWIND result.points as points
RETURN points, teamName
//output only the first 5 times as requested and order them from higher to lower
ORDER BY points DESC LIMIT 5

//72 + 11 = 83
// HT WINS = 24 * 3 = 72
MATCH
(t:Team{name:"Liverpool FC"})-[r]->(m:Match)<-[r2]-(t2:Team)
WHERE r.goalsScoredHT > r2.goalsScoredHT
RETURN COUNT(r)

// HT DRAWS = 11 * 1 = 11
MATCH
(t:Team{name: "Liverpool FC"})-[r]->(m:Match)<-[r2]-(t2:Team)
WHERE r.goalsScoredHT = r2.goalsScoredHT
RETURN COUNT(r)




//EIGTH Alternate
//Get all the matches and teams (one team at a time)
MATCH (t:Team)-[r]->(m:Match)
//Calculate the sum total of the scores in half time
//all the goals scored by the team in half time, exist in the relationships
//that connect it and the matches played
RETURN t.name AS `Team Name`, sum(r.goalsScoredHT) AS allGoals
ORDER BY allGoals DESC LIMIT 5


//NINTH
//Show teams with the most "loss" score
//The first query is only to get the maximum value of the losses
MATCH (n:Team)-[r:LOST]->(m:Match)
//Counting wins
WITH n, COUNT(r) as count
//Keeping the maximum value
WITH MAX(count) as max
//Querrying again
MATCH (n:Team)-[r:LOST]->(m:Match)
WITH n, COUNT(r) as count, max
//Keeping only the results whose lose count is equal with the max
WHERE count = max
RETURN n.name as `Team Name`, count as `Losses`




//TENTH
	//Team with most consecutive wins
MATCH
//get wins,losses and draws of each team
(t:Team)-[r:WON|LOST|DRAW]->(m:Match)
//dealing with relationship types, passing down the name and
//making an array out of the month and the day (both numbers)
//this is needed because the results MUST be ordered based on the date
WITH type(r) as matchResult, t.name as teamName, collect([m.month, m.day]) as list
//create a list of dates(month no, monthDay no)
UNWIND list AS datesList
//pass down the variables for further proccessing
WITH teamName, matchResult, datesList
//order everything by the dates
ORDER BY datesList
//REDUCE will perform an action foreach item in out list of relationship types
RETURN teamName, REDUCE(s = {bestStreak: 0, currentStreak: 0}, result IN COLLECT(matchResult) |
//if WON is found
  CASE WHEN result = "WON"
    THEN {
      //the bestStreak variable represents the highest amount of consecutive wins for a team, throughtout the loop
      //the currentStreak counts how many consecutive wins between dates
      //once the currentStreak + 1 is bigger than the previous high score, the bestStreak is updated with the new high score
      //else it remains the same
      bestStreak: CASE WHEN s.bestStreak < s.currentStreak + 1 THEN s.currentStreak + 1 ELSE s.bestStreak END,
      currentStreak: s.currentStreak + 1
    }
    //if anything else than win, bestStreak is saved and current streak is nullified since this streak is broken
    ELSE {bestStreak: s.bestStreak, currentStreak: 0}
  END
  //we are concerned about the bestStreak of the teams so we return it
  //ordering by it and limiting by 1 to get one team
  ).bestStreak AS result
  ORDER BY result DESC LIMIT 1;
