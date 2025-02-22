#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Function to display services
display_services() {
    echo -e "\nHere are the services we offer:"
    SERVICES=$($PSQL "SELECT * FROM services")
    #echo "$SERVICES"
    echo "$SERVICES" | while read SERVICE
    do
      echo "$SERVICE" | sed 's/|/) /'
    done
}

display_services
# Get service_id
echo "Please enter a service ID:"
read SERVICE_ID_SELECTED

while true; do
  SERVICE_EXISTS=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ $SERVICE_EXISTS -gt 0 ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    break
  else
    display_services
    echo "Invalid service ID. Please choose again:"
    read SERVICE_ID_SELECTED
  fi
done

echo "Please enter your phone number:"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [ -z "$CUSTOMER_ID" ]
then
    # Customer doesn't exist, ask for name and add them
    echo "Phone number not found. Please enter your name:"
    read CUSTOMER_NAME
    ADD_CUSTOMER_RES=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
echo "$($PSQL "SELECT name, phone FROM customers WHERE customer_id=$CUSTOMER_ID")" | sed -E 's/(.+)\|(.+)/Hello \1 (phone: \2)/'
echo "Please enter the time for the appointment:"
read SERVICE_TIME

# Add appointment
INSERT_SERVICE_RES=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
# Output confirmation message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
