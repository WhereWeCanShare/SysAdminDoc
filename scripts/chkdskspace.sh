#!/bin/bash
### Author: cHoo
### Date: August 2019
### Description: Script to dump database and ftp to NAS.
### Version: 1.01
#### 1.02 add sending the message to Telegram

#
# Import global variable
#
CONFLE="/opt/scripts/setting-global.ini"
if [ -f $CONFLE ]
then
    source $CONFLE
    LINEMSG="\n$HOSTNAME: $0"
else
    LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
    LINETOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    LINEMSG="$0 - $LOGTIME - $CONFLE not found."
    curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" https://notify-api.line.me/api/notify
    echo -e "\n"
    exit
fi

# define variables
LOGDIR="$HOME/logs"
LOGFILE="$LOGDIR/diskspace.log"
LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')

if [ ! -d $LOGDIR ]
then
    mkdir "$LOGDIR"
    touch "$LOGFILE"
fi

echo "-- $LOGTIME - Disk space statistic on $HOSTNAME" >> $LOGFILE 2>&1
df -h | grep '^/dev/' >> $LOGFILE 2>&1
echo -e "\n" >> $LOGFILE 2>&1

LINEMSG=$(echo -e "$HOSTNAME: $0 DiskInfo $LOGTIME\n<pre>" && df -h | grep '^File' && df -h | grep '^/dev/' && echo -e "</pre>\n")

#
# LINE Notify
#
#curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" https://notify-api.line.me/api/notify

# Telegram
curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$LINEMSG" -d "parse_mode=HTML"
echo -e "\n"
