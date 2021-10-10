#!/bin/bash
### Author: cHoo
### Date: August 2019
### Description: Script to dump psql database.
### Version: 
#### 1.01 - update messages.
#### 2.00 - code defactor to improve multiprocess/multithread.
#### 2.03 - 202109 revise code and message.

#
# Import global variable
#
CONFLE="/opt/scripts/setting-global.ini"
if [ -f $CONFLE ]
then
    source $CONFLE
    LINEMSG="$0 on $HOSTNAME"
else
    LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
    LINETOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    LINEMSG="$0 - $LOGTIME - $CONFLE not found."
    curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" https://notify-api.line.me/api/notify
    echo -e "\n"
    exit
fi

# define the variables
BAKDIR="$HOME/bak"
BAKLOG="$BAKDIR/bkup_db.log"

if [ ! -d $BAKDIR ]
then
    mkdir "$BAKDIR"
    touch "$BAKLOG"
fi


# Function
function dump_compress() {
    # dump db    
    LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
    MSGLOG="<pre>$LOGTIME start dump: $i"
    echo -e $MSGLOG >> $BAKLOG
    LINEMSG+="\n$MSGLOG"
    
    /usr/bin/pg_dump $i -f $BAKTIME-$i.sql
    SQLSIZE=$(du -h $BAKTIME-$i.sql | awk {'print $1'})

    # compress bakfile
    LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
    MSGLOG="$LOGTIME start compress: $i"
    echo -e $MSGLOG >> $BAKLOG
    LINEMSG+="\n$MSGLOG"
    
    tar -cz --remove-files -f $BAKTIME-$i.tgz $BAKTIME-$i.sql >> $BAKLOG 2>&1
    TGZSIZE=$(du -h $BAKTIME-$i.tgz | awk {'print $1'})

    # Job duration calculation
    ENDTIME=$(date +%s)
    RUNTIME=$((ENDTIME-STARTTIME))
    RUNSEC=$(($RUNTIME%60))
    RUNMIN=$(((($RUNTIME-$RUNSEC)/60)%60))
    RUNHRS=$(($RUNTIME/3600))

    LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
    MSGLOG="\n$LOGTIME DB: $i (SQL:$SQLSIZE/TGZ:$TGZSIZE) DONE \n</pre>\nElapsed time: $RUNHRS:$RUNMIN:$RUNSEC"
    echo  -e $MSGLOG >> $BAKLOG
    LINEMSG+=$MSGLOG

    if [ $i != "postgres" ]
    then
        LINEMSG=$(echo -e $LINEMSG)
        
        ## LINE Notify
        # curl -X POST -H "Authorization: Bearer $LINETOKEN" -F "message=$LINEMSG" https://notify-api.line.me/api/notify

        # Telegram Bot
        curl -X POST https://api.telegram.org/bot$TGKEY/sendmessage -d "chat_id=$CHATID" -d "text=$LINEMSG" -d "parse_mode=HTML"

    fi
}


# Start the backup
BAKTIME=$(date '+%Y%m%d_%H%M')
LOGTIME=$(date '+%Y-%m-%d_%H:%M:%S')
STARTTIME=$(date +%s)
echo -e "\n--- Daily Backup $LOGTIME ---" >> $BAKLOG 

cd $BAKDIR || exit
DBS=$(psql -q -c "\l" | sed -n 4,/\eof/p | grep -v rows\) | grep -v template0 | grep -v template1 | grep -v CTc | awk {'print $1'})
for i in $DBS; do
    dump_compress $i &
done
