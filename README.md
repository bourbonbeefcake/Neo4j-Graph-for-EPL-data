# Neo4j Graph database for EPL Data

In this project, matches and teams of the English Premier League was given in a CSV format. Loading the CSV into Neo4j was designed and implemented along with a variety of useful queries.

All queries are heavily commented.

## Load the Database on Neo4j Desktop:

1. On an empty graph of your selection, click &quot;Manage&quot;
2. Click &quot;Open Folder&quot; on top
3. Copy and paste the CSV file into the &quot;import&quot; folder
4. Open the Neo4j Browser
5. Copy and paste the query from the &quot;csvLoad.cypher&quot; file into the command line and run it
6. The following numbers should come up as a result of the query

![Graph Design](https://github.com/antoniosTriant/Neo4j-Graph-for-EPL-data/blob/master/documentation/images/Neo4j%20query%20result%20screenshot.jpg)

## Queries Documentation

1. Displays how many matches were played in the EPL
2. Displays details of all matches involved &quot;Manchester United FC&quot;.
3. Displays all the teams that played the EPL matches in the season.
4. Displays the team with the most &quot;win&quot; in January.
5. Displays the top five teams that have the best scoring power.
6. Displays the top five teams that have the worst defending.
7. Displays top five teams that have the best winning records.
8. Displays top five teams with best half time result.
9. Which teams had the most &quot;loss&quot;?
10. Displays the team with the most consecutive &quot;win&quot;.

## Graph Model Design

![Graph Design](https://github.com/antoniosTriant/Neo4j-Graph-for-EPL-data/blob/master/documentation/images/Neo4j%20design.jpg)

Considering the queries that are requested and the analysis of the CSV, the following design was decided:

The advantage of this design, is that it is straightforward, easily maintainable and easily queried. It would only be needed to add matches if this graph held all the records for every EPL and teams only in case there were new teams in the league.
