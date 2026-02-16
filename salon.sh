#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
SERVICES=$($PSQL "SELECT service_id, name FROM services")

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo "$SERVICES" | while IFS='|' read ID SERVICE
  do
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
}

MAIN_MENU "What kind of service would you like to reserve?"
# if doesn't exist, show original list
SELECTION_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
if [[ -z $SELECTION_RESULT ]]
then
  MAIN_MENU "Please select an existing service number."
else
  # enter phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # if new, ask for name, and add for customer table
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  # enter time
  echo -e "\nWhat time should we reserve for you, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # create an entry in appointments table
  APP_INSERT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  if [[ $APP_INSERT_RESULT != "INSERT 0 1" ]]
  then
    MAIN_MENU "This appointment is already reserved."
  else
    # after the appointment is added, print a confirmation message
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi



