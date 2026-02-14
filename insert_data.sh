#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get winner team id and opponent team id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # if winner team not found
    if [[ -z $WINNER_ID ]]
    then
      # insert into teams table
      WINNER_INSERT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      # get new winner id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi
    # if opponent team not found
    if [[ -z $OPP_ID ]]
    then
      # insert into teams table
      OPP_INSERT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      # get new opponent id
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi
    # insert into games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
    
