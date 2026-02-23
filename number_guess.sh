#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USER

USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USER'")
if [[ -z $USERNAME_RESULT ]]
then
  GAMES=0
  BEST=1000
  INSERT_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USER', $GAMES, $BEST)")
  echo "Welcome, $USER! It looks like this is your first time here."
else
  GAMES=$($PSQL "SELECT games_played FROM users WHERE username = '$USER'")
  BEST=$($PSQL "SELECT best_game FROM users WHERE username = '$USER'")
  echo "Welcome back, $USERNAME_RESULT! You have played $GAMES games, and your best game took $BEST guesses."
fi

function GAME() {
  if [[ -z $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
  elif [[ $1 = 'notint' ]]
  then 
    echo "That is not an integer, guess again:"
  elif [[ $1 = 'lower' ]]
  then
    echo "It's lower than that, guess again:" 
  elif [[ $1 = 'higher' ]]
  then
    echo "It's higher than that, guess again:"
  fi

  read GUESS
}

#echo $SECRET

GUESS_NUM=0

GAME

until [[ $GUESS = $SECRET ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then 
    # if it's not a valid input, error message
    ((GUESS_NUM+=1))
    GAME notint
  elif (( GUESS > SECRET ))
  then
    # check if it's lower or higher -> message, and new guess
    # increase the number of guesses after each guess
    ((GUESS_NUM+=1))
    GAME lower 
  elif (( GUESS < SECRET ))
  then
    ((GUESS_NUM+=1))
    GAME higher
  fi
done
# output the good guess message
((GUESS_NUM+=1))
# increase the played games number, update the best guess number
((GAMES+=1))
GAMES_TO_UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES WHERE username = '$USER'")
if (( BEST > GUESS_NUM ))
then
  BEST_TO_UPDATE=$($PSQL "UPDATE users SET best_game = $GUESS_NUM WHERE username = '$USER'")
fi

echo "You guessed it in $GUESS_NUM tries. The secret number was $SECRET. Nice job!"
