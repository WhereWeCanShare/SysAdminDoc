#!/bin/bash

### Date: December 2022
### Description: Script to send a notification to Telegram about the RCLONE status.
### Version: 
#### 0.1 - initial release

#
# Import global variable
#
CONFLE="/opt/scripts/setting-global.ini"
source $CONFLE
MSGLOG="$0 on $HOSTNAME\n"

# initial variables
STARTTIME=`date +%s`
LOGTIME=$(date '+%Y-%m-%d %H:%M - ')
MSGLOG+="\n<pre>$LOGTIME start RCLONE $1 on $2"
curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$LOGTIME Start rclone $1 on $HOSTNAME:$2 " -d "parse_mode=HTML"

if [ -n "$1" ]; then
    CMD="copy"
else
    CMD="$1"
fi

## Execution
rclone $CMD -P --log-file="/tmp/rclone.log" --skip-links --exclude-from ~/.excl-rclone $2 $3
STATUS=$?
LOGTIME=$(date '+%Y-%m-%d %H:%M - ')

if [ $STATUS == 0 ] ; then
    MSGLOG+="\n$LOGTIME successful</pre>"
else
    MSGLOG+="\n$LOGTIME rclone failed code $STATUS.</pre> \nExit-code list here, https://rclone.org/docs/#exit-code"
fi

# Job duration calculation
ENDTIME=$(date +%s)
RUNTIME=$((ENDTIME-STARTTIME))
RUNSEC=$(($RUNTIME%60))
RUNMIN=$(((($RUNTIME-$RUNSEC)/60)%60))
RUNHRS=$(($RUNTIME/3600))
MSGLOG+="\n\nElapsed time: $RUNHRS:$RUNMIN:$RUNSEC"

# send the message
MSGLOG=$(echo -e $MSGLOG)
curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$MSGLOG" -d "parse_mode=HTML"
echo -e "\n"