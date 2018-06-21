#!/bin/bash
#Script to check ip address changes and push as notification with slack

IP_FILE=/var/check-ip/current-ip
SLACK_URI=
INTERFACE=eth0

generate_json()
        {
                cat <<EOF
                {
                        "text": "$HOSTNAME has a new IP address:\n$IP"
                }
EOF
        }

while :
do
        IP=$(cat $IP_FILE)
        while [ "$IP" == "$(ifconfig $INTERFACE | sed -n 's/.*inet\saddr:\([^ ]*\).*/\1/gp')" ]\
        || [ "" == "$(ifconfig $INTERFACE | sed -n 's/.*inet\saddr:\([^ ]*\).*/\1/gp')" ]
        do
                sleep 1h
        done

        IP=$(ifconfig $INTERFACE | sed -n 's/.*inet\saddr:\([^ ]*\).*/\1/gp')
        echo "$IP" > $IP_FILE
        ##send notification
        curl \
        -X POST \
        -H 'Content-type: application/json' \
        --data "$(generate_json)" \
        $SLACK_URI
        ##log it
        logger check-ip detected new ip address.  Slack notification sent.
done