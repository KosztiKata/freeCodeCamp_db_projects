#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ [0-9]+ ]]
  then
    INPUT_RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number LEFT JOIN types ON properties.type_id=types.type_id WHERE elements.atomic_number = $1")
  else
    INPUT_RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number LEFT JOIN types ON properties.type_id=types.type_id WHERE elements.symbol = '$1' OR elements.name = '$1'")
  fi
  if [[ -z $INPUT_RESULT ]]
  then
    echo I could not find that element in the database.
  else
    echo $INPUT_RESULT | while IFS='|' read NUM SYMBOL NAME x MASS MELT BOIL x x TYPE
    do
      echo "The element with atomic number $NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done
  fi
fi
