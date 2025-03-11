#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n✂️ ~~~ Welcome to Glamour Haven Salon ~~~ ✂️\n"
echo -e "Step right in! How can we pamper you today?\n"

# Function to display services with flair
SHOW_SERVICES() {
  echo -e "✨ Our Fabulous Offerings ✨"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]; then
    echo "Oops! It seems we’re fresh out of services today. Check back soon!"
  else
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "  $SERVICE_ID) $SERVICE_NAME"
    done
  fi
}

# Function to get a valid service ID with a while loop
GET_SERVICE() {
  while true; do
    SHOW_SERVICES
    echo -e "\nPick your treat (enter the number):"
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      echo -e "\nHmm, numbers only, please! Let’s try that again..."
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | xargs)
      if [[ -z $SERVICE_NAME ]]; then
        echo -e "\nThat’s not on our menu! Let’s pick something fabulous..."
      else
        break
      fi
    fi
  done
}

# Function to handle customer details and booking
BOOK_APPOINTMENT() {
  echo -e "\n📞 Let’s get you booked! What’s your phone number?"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nNew face, new grace! What’s your name, darling?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  fi

  echo -e "\n⏰ When would you like your $SERVICE_NAME, $CUSTOMER_NAME? (e.g., 2pm)"
  read SERVICE_TIME

  # Book the appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)
  INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_RESULT == "INSERT 0 1" ]]; then
    echo "🎉 All set! You’re booked for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo "Uh-oh! Something went wrong with your booking. Please try again!"
    exit 1
  fi
}

# Main flow
MAIN_SALON() {
  GET_SERVICE
  BOOK_APPOINTMENT
}

# Start the magic
MAIN_SALON