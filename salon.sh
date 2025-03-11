#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # Display services
  echo "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]; then
    echo "Sorry, we don't have any services right now."
  else
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  fi

  # Prompt for service ID
  echo -e "\nPlease enter a service ID:"
  read SERVICE_ID_SELECTED

  # Validate service ID
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Sorry, that is not a valid number! Please, choose again."
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | xargs)
    if [[ -z $SERVICE_NAME ]]; then
      MAIN_MENU "I could not find that service. Please select a valid service."
    else
      # Prompt for phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # Check if customer exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)
      if [[ -z $CUSTOMER_NAME ]]; then
        # New customer: prompt for name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
      fi

      # Prompt for time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # Insert appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)
      INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $INSERT_RESULT == "INSERT 0 1" ]]; then
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo "Sorry, there was an error scheduling your appointment. Please try again."
        exit 1
      fi
    fi
  fi
}

# Run script
MAIN_MENU
