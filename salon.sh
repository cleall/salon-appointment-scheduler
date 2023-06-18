#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n***** Salon *****\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available services
  echo -e "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
    read SERVICE_ID_SELECTED

  # if service id is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu and show services list again
      MAIN_MENU "I could not find that service. Please try again"
  else
    # search service existance
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # if service does not exist
    if [[ -z $SERVICE_NAME ]]
    then
      # send to main menu or finish execution ?
      #MAIN_MENU "I could not find that service. Please try again"
      echo -e "\nService not offered at the moment."
    else
      # get appointment data
      APPOINTMENT_MENU
    fi
  fi
}

APPOINTMENT_MENU() {
  # ask for customer phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # if phone is not valid
  #if [[ ! "$CUSTOMER_PHONE" =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
  #then
    # send to main menu or finish execution ?
    #MAIN_MENU "Please enter a valid phone number."
    #echo -e "\nPlease enter a valid phone number."
  #else
    #get customer name from db
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # if customer name is not valid
      if [[ ! $CUSTOMER_NAME =~ ^([a-zA-Z ])+$ ]]
      then
        # send to main menu or finish execution ?
        #MAIN_MENU "Please enter a valid name."
        echo -e "\nPlease enter a valid name."
      else
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        # if customer is not created
        if [[ $INSERT_CUSTOMER_RESULT != "INSERT 0 1" ]]
        then
          # send to main menu or finish execution ?
          #MAIN MENU "Could not complete appointment. Please try again."
          echo -e "\nCould not register new customer. Please try again."
        fi
      fi
    #fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #get service time
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    # if service time is not valid
    #if [[ ! $SERVICE_TIME =~ ^((0[7-9])?|1[0-9])(am|pm)?:?[0-5]?[0-9]?(am|pm)?$ ]]
    #then
      # send to main menu or finish execution ?
      #MAIN_MENU "I could not understand your desired service time."
      #echo -e "\nI could not understand your desired service time."
    #else
      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES ('$SERVICE_TIME',$CUSTOMER_ID, $SERVICE_ID_SELECTED)")
      # if appointment fails
      if [[ $INSERT_APPOINTMENT_RESULT != "INSERT 0 1" ]]
      then
        # send to main menu or finish execution ?
        #MAIN MENU "Could not complete appointment. Please try again."
        echo -e "\nCould not complete appointment. Please try again."
      else
        # complete and notify appointment result
        echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED.\n"
      fi
    #fi
  fi
}

MAIN_MENU "Welcome, what can i do for you?"
