#!/usr/bin/bash

SETTINGS_PATH=/etc/no-ip-updater.settings

OUTPUT=/tmp/no-ip-updater.data
LOG=/var/log/no-ip-updater.log
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
	curl -s -o $OUTPUT \
		--interface $INTERFACE \
		http://ip1.dynupdate.no-ip.com/

	EXTERNAL_IP=$(cat $OUTPUT)
	printf "> Got IP %s\n" "$EXTERNAL_IP"

	printf "> Checking last set address\n"
	curl -s -vvv -o $OUTPUT \
		--interface $INTERFACE \
		--netrc-file $NETRC_PATH \
		"http://dynupdate.no-ip.com/nic/update?hostname=$GROUP&myip=$EXTERNAL_IP" 2> $LOG
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
