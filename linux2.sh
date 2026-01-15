#!/bin/bash

# The linux shell scripting handson assignment

# creating the variable and assigning that to file sig.conf
CONF_FILE="sig.conf"

# reading user input using CASE statement to choose component name
read -p "Enter component name [INGESTOR/JOINER/WRANGLER/VALIDATOR]: " COMPONENT 
case "$COMPONENT" in 
	INGESTOR|JOINER|WRANGLER|VALIDATOR)
	;;
*)
	echo "Invalid component name"
	exit 1
	;;

esac

# reading user input using CASE statement to choose scale
read -p "Enter Scale [MID/HIGH/LOW]: " SCALE

case "$SCALE" in 
	MID|HIGH|LOW)
    ;;
*)
    echo "Invalid Scale"
    exit 1
    ;;
esac

# reading user input using CASE statement to choose view
read -p "Enter View [Auction/Bid]: " VIEW

case "$VIEW" in
  Auction)
    VIEW_VALUE="vdopiasample"
    ;;
  Bid)
    VIEW_VALUE="vdopiasample-bid"
    ;;
  *)
    echo "Invalid View"
    exit 1
    ;;
esac

# reading user input to take number of count
read -p "Enter Count [0-9]: " COUNT

if [[ ! "$COUNT" =~ ^[0-9]$ ]]; then
  echo "Invalid Count enter number range 0-9"
 
  exit 1
fi

# create new variable called NEW_LINE  and store all the input we took from the user in certain formate
NEW_LINE="${VIEW_VALUE} ; ${SCALE} ; ${COMPONENT} ; ETL ; vdopia-etl=${COUNT}"

# create the file sig.conf backup 
cp "$CONF_FILE" "${CONF_FILE}.bak"

# using awk to scan the sig.conf file line by line and find the first line
# that exactly matches the given view, scale, and component values provided by the user
# once the first matching line is found, it replaces that line with the new configuration
# and prints all remaining lines without any further changes

awk -v view="$VIEW_VALUE" \
    -v scale="$SCALE" \
    -v comp="$COMPONENT" \
    -v newline="$NEW_LINE" '
BEGIN { updated=0 }
{
    pattern = "^" view " ; " scale " ; " comp " ; ETL ; vdopia-etl=[0-9]$"

    if (!updated && $0 ~ pattern) {
        print newline
        updated=1
    }
    else {
        print
    }
}
' "$CONF_FILE" > /tmp/sig.conf.tmp && mv /tmp/sig.conf.tmp "$CONF_FILE"


# successful message 
echo "The configuration updated."
echo "Backup created: ${CONF_FILE}.bak"

