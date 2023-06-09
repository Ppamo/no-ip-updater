#!/usr/bin/bash

SETTINGS_PATH=/etc/no-ip-updater.settings

OUTPUT=/tmp/no-ip-updater.data
DATA=/var/log/no-ip-updater.prop
DATE=$(date +%Y%m%d.%H%M%S)

if [ -f $SETTINGS_PATH ]; then
	printf "> Loading %s file\n\n" "$SETTINGS_PATH"
	. $SETTINGS_PATH
fi

[ -z "$INTERFACE" ] && echo "INTERFACE var not set" && exit 1
[ -z "$GROUP" ] && echo "GROUP var not set" && exit 1
[ -z "$SLEEP_PERIOD" ] && echo "SLEEP_PERIOD var not set" && exit 1
[ -z "$NETRC_PATH" ] && echo "NETRC_PATH var not set" && exit 1

while true; do
	rm -f $OUTPUT
	DATE="$(date --rfc-3339=ns)"

	printf "> %s\n" "$DATE"
	printf "> Getting external IP address:\n"
	curl -vvv -o $OUTPUT \
		--interface $INTERFACE \
		http://ip1.dynupdate.no-ip.com/

	if [ $?  -ne 0 ]; then
		printf "> Error getting external IP address\n"
		sleep 3
		exit 1
	fi

	EXTERNAL_IP=$(cat $OUTPUT)
	printf "> Got IP %s\n" "$EXTERNAL_IP"

	printf "> Updating address\n"
	curl -vvv -o $OUTPUT \
		--interface $INTERFACE \
		--netrc-file $NETRC_PATH \
		"http://dynupdate.no-ip.com/nic/update?hostname=$GROUP&myip=$EXTERNAL_IP"

	if [ $?  -ne 0 ]; then
		printf "> Error updating IP address\n"
		sleep 3
		exit 1
	fi

	RESPONSE=$(cat $OUTPUT)
	printf "> Response %s\n" "$RESPONSE"

	RESPONSE_CODE=${RESPONSE% *}
	RESPONSE_IP=${RESPONSE#* }
	printf "TIMESTAMP: %s
INTERFACE: %s
GROUP: %s
EXTERNAL_IP: %s
RESPONSE_CODE: %s
RESPONSE_IP: %s
" "$DATE" "$INTERFACE" "$GROUP" "$EXTERNAL_IP" "$RESPONSE_CODE" "$RESPONSE_IP" > $DATA
	printf "> Sleeping...\n\n"
	sleep $SLEEP_PERIOD
done
