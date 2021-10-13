#!/bin/bash
### Author: cHoo
### Date: October 2021
### Description: Script to send the IPv6 address to Dynv6.com
### Version: 1.0

# initial variables
SRVNAME="srv001"
ZONEID=1234567
RECID=7654321
TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
## get the current ipv6 address
IPV6=$(ip -6 a | grep mngtmpaddr | awk {'print $2'} | sed  's/\/64//g')
## json to send
RAWDATA="{\"name\":\"$SRVNAME\",\"data\":\"$IPV6\"}"

## check for any IPv6 address change.
if [ -f /tmp/IPV6_1.tmp ]
then
   IPV6_1=$(</tmp/IPV6_1.tmp)
   if [ $IPV6_1 == $IPV6 ]
   then
      exit
   fi
fi

echo "Updatinng IPv6"
curl --location --request PATCH "https://dynv6.com/api/v2/zones/$ZONEID/records/$RECID" \
--header "Authorization: Bearer $TOKEN" \
--header "Content-Type: application/json" \
--data-raw "$RAWDATA"
echo $IPV6 > /tmp/IPV6_1.tmp
