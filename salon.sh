#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

MAIN_MENU() {

    if [[ $1 ]]
    then
        echo -e "\n$1"
    else
        echo -e "\n~~Salon Appointment Scheduler~~\n"
    fi

    echo "Welcome to My Salon, how can I help you?"

    SERVICES=$($PSQL "SELECT * FROM services")
    echo "$SERVICES" | while IFS="|" read ITEM NAME
    do
        echo "$ITEM) $NAME"
    done

    echo "Enter an option:"
    read SERVICE_ID_SELECTED

    case $SERVICE_ID_SELECTED in
    1) APPOINT_MENU 1 ;;
    2) APPOINT_MENU 2 ;;
    3) APPOINT_MENU 3 ;;
    *) MAIN_MENU "Please enter a valid option." ;;
    esac
}

APPOINT_MENU() {
    echo "You selected $($PSQL "SELECT name FROM services WHERE service_id=$1")"
    echo "What's your phone number?"
    read CUSTOMER_PHONE

    CLIENT_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CLIENT_ID ]]
    then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CLIENT_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CLIENT_ID")

    echo "What time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")

    APPOINMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CLIENT_ID', $1, '$SERVICE_TIME')")

    if [[ $APPOINMENT_INSERT_RESULT == "INSERT 0 1" ]]
    then
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}


MAIN_MENU