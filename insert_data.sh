#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into games and teams tables

# 1) Empty tables before insert
echo $($PSQL "TRUNCATE TABLE games, teams;")

# 2) Insert into teams

INSERTED_TEAM='Inserted team:'

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Find winner team_id
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  # If not found, insert winner
  if [[ -z $TEAM_ID && $WINNER != 'winner' ]] 
  then
    INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
    if [[ $INSERT_WINNER == 'INSERT 0 1' ]]
    then
      echo $INSERTED_TEAM $WINNER
    fi
  fi
  # Find opponent team_id
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  # If not found, insert opponent
  if [[ -z $TEAM_ID && $OPPONENT != 'opponent' ]] 
  then
    INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
    if [[ $INSERT_OPPONENT == 'INSERT 0 1' ]]
    then
      echo $INSERTED_TEAM $OPPONENT
    fi
  fi
done

# 3) Insert into games

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Ignore first row
  if [[ $YEAR != 'year' ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    echo Inserted Game: $YEAR, Round: $ROUND
  fi 
done