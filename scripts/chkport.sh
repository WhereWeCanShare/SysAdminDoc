#!/bin/bash
### Author: cHoo
### Date: September 2019
### Description: Script to check host port
### Version: 
#### 1.0 - initial
#### 1.1 - Check the flag file not to repeat more than 3 times.
#### 1.2 - 202110 add sending to Telegram
#
# Import global variable
#

CONFLE="/opt/scripts/setting-global.ini"
if [ -f $CONFLE ]
then
    source $CONFLE
    LINEMSG="$HOSTNAME: $0"

else
    LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
    LINETOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    LINEMSG="$0 - $LOGTIME - $CONFLE is missing"
    curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" -F "stickerPackageId=1" -F "stickerId=6" https://notify-api.line.me/api/notify
    echo -e "\n"
    exit
fi

## Start the script work here.
### Service Level resolve time, update this seconds according to your SLA
SLARESLV='1800'                      
LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')

if nc -z $1 $2 > /dev/null; then
    if test -f "/tmp/chkport-$1_$2.bad" ; then
        rm /tmp/chkport-$1_$2.bad
    fi
    if test -f "/tmp/chkport-$1_$2.good" ; then
        exit
    fi
    LINEMSG+="\n$LOGTIME - start to check $1:$2 $3"
    LINEMSG=$(echo -e "$LINEMSG")
    ## LINE
    curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" https://notify-api.line.me/api/notify
    ## Telegram
    curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$LINEMSG"
    echo "$1:$2 checked at $LOGTIME" > /tmp/chkport-$1_$2.good
    
else
    if test -f "/tmp/chkport-$1_$2.bad" ; then
        INCTIME=$(stat -c %Y /tmp/chkport-$1_$2.bad)
        CHKTIME=$(date '+%s')
        INTERVL=$((CHKTIME-INCTIME))
        if [ $INTERVL -gt $SLARESLV ]; then
            LINEMSG+="$1:$2 is still down, please fix."
            curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" https://notify-api.line.me/api/notify
            curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$LINEMSG" 
            touch /tmp/chkport-$1_$2.bad
        fi
    else
        LINEMSG+="\n$LOGTIME - $1:$2 $3 stop working"
        LINEMSG=$(echo -e $LINEMSG)
        LINESTKID="123"
        curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" -F 'stickerPackageId=1' -F "stickerId=$LINESTKID" https://notify-api.line.me/api/notify
	    curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$LINEMSG"

        if test -f "/tmp/chkport-$1_$2.good" ; then rm /tmp/chkport-"$1"_"$2".good ; fi
        echo "$1:$2 stop working, check at $LOGTIME" >> /tmp/chkport-"$1"_"$2".bad
    fi
fi
