#=============================================================================================================================================
# File Name     : /home/yesdb/LinuxHealthCheck.sh
# Author        : Seetha Ram.M
# Description   : Server Health Check
#=============================================================================================================================================
#!/bin/bash

mkdir -p /home/yesdb/HealthCheck
DATE=`date +%F' '%T`
LOGFILE=/home/yesdb/HealthCheck/ServerHealthCheck.csv
touch $LOGFILE

VERSION=`cat /etc/redhat-release`

if free | grep -q available
then
	# Red Hat Enterprise Linux SERVER RELEASE 7.6 (Maipo)
	# MemUse=ps -o pid,user,%mem,command ax|grep -v MEM|awk '{sum +=$3}END{print sum}'
	MemUse=$(free | sed -n 2p | awk '{print $3}')
	MemTot=$(free | sed -n 2p | awk '{print $2}')
	df -Pl | awk '/^\/dev/ {print $1,"~",$2,"~",$3,"~",$4,"~",$5,"~",$6,"~RHEL7"}'| tr ' ' '\0' | tr '~' '|' | tr '\n' ';' > /home/yesdb/HealthCheck/DF
	DiskStat=(`cat /home/yesdb/HealthCheck/DF`)
elif echo $VERSION | grep -q Tikanga
then 
	# Red Hat Enterprise Linux SERVER RELEASE 5.8 (Tikanga)
	# MemFre=$(free | sed -n 3p | awk '{print $4}')
	# MemUse=ps -o pid,user,%mem,command ax|grep -v MEM|awk '{sum +=$3}END{print sum}'
	MemUse=`expr $MemTot - $MemFre`
	MemTot=$(free | sed -n 2p | awk '{print $2}')
	df -Pl | awk '/^\/dev/ {print $1,"~",$2,"~",$3,"~",$4,"~",$5,"~",$6,"~RHEL5"}'| tr ' ' '\0' | tr '~' '|' | tr '\n' ';' > /home/yesdb/HealthCheck/DF
	DiskStat=(`cat /home/yesdb/HealthCheck/DF`)
elif echo $VERSION | grep -q Santiago
then
	# Red Hat Enterprise Linux SERVER RELEASE 6.9 (Santiago)
	# MemUse=ps -o pid,user,%mem,command ax|grep -v MEM|awk '{sum +=$3}END{print sum}'
	MemUse=$(free | sed -n 3p | awk '{print $3}')
	MemTot=$(free | sed -n 2p | awk '{print $2}')
	df -Pl | awk '/^\/dev/ {print $1," ",$2," ",$3," ",$4," ",$5," ",$6}' | sort -u > /home/yesdb/HealthCheck/DF
	df | awk '/^\/dev/ {print $1}' | xargs -I {} sh -c 'echo {}; sudo /sbin/tune2fs -l {}' | awk '/^\/dev/ {print $1}; /^Filesystem state/'| awk 'ORS=NR%2?FS:RS' | sort -u > /home/yesdb/HealthCheck/DS
	join -j 1 -o 1.1,1.2,1.3,1.4,1.5,1.6,2.4 /home/yesdb/HealthCheck/DF /home/yesdb/HealthCheck/DS | tr '\n' ';'| tr ' ' '|' > /home/yesdb/HealthCheck/DISK
	DiskStat=(`cat /home/yesdb/HealthCheck/DISK`)
#elif echo $VERSION | grep -q Maipo
#then
#	# Red Hat Enterprise Linux Server release 7.6 (Maipo)
#	# MemUse=ps -o pid,user,%mem,command ax|grep -v MEM|awk '{sum +=$3}END{print sum}'
#	MemUse=$(free | sed -n 3p | awk '{print $3}')
#	MemTot=$(free | sed -n 2p | awk '{print $2}')
#	df -Pl | awk '/^\/dev/ {print $1," ",$2," ",$3," ",$4," ",$5," ",$6}' | sort -u > /home/yesdb/HealthCheck/DF
#	df | awk '/^\/dev/ {print $1}' | xargs -I {} sh -c 'echo {}; sudo /sbin/tune2fs -l {}' | awk '/^\/dev/ {print $1}; /^Filesystem state/'| awk 'ORS=NR%2?FS:RS' | sort -u > /home/yesdb/HealthCheck/DS
#	join -j 1 -o 1.1,1.2,1.3,1.4,1.5,1.6,2.4 /home/yesdb/HealthCheck/DF /home/yesdb/HealthCheck/DS | tr '\n' ';'| tr ' ' '|' > /home/yesdb/HealthCheck/DISK
#	DiskStat=(`cat /home/yesdb/HealthCheck/DISK`)
elif echo $VERSION | grep -q CentOS
then
	# CentOS release 6.8 (Final)
	# MemUse=ps -o pid,user,%mem,command ax|grep -v MEM|awk '{sum +=$3}END{print sum}'
	MemUse=$(free | sed -n 3p | awk '{print $3}')
	MemTot=$(free | sed -n 2p | awk '{print $2}')
	df -Pl | awk '/^\/dev/ {print $1," ",$2," ",$3," ",$4," ",$5," ",$6}' | sort -u > /home/yesdb/HealthCheck/DF
	df | awk '/^\/dev/ {print $1}' | xargs -I {} sh -c 'echo {}; sudo /sbin/tune2fs -l {}' | awk '/^\/dev/ {print $1}; /^Filesystem state/'| awk 'ORS=NR%2?FS:RS' | sort -u > /home/yesdb/HealthCheck/DS
	join -j 1 -o 1.1,1.2,1.3,1.4,1.5,1.6,2.4 /home/yesdb/HealthCheck/DF /home/yesdb/HealthCheck/DS | tr '\n' ';'| tr ' ' '|' > /home/yesdb/HealthCheck/DISK
	DiskStat=(`cat /home/yesdb/HealthCheck/DISK`)
else
	# Unknown
	MemUse=ps -o pid,user,%mem,command ax|grep -v MEM|awk '{sum +=$3}END{print sum}'
	# MemUse=$(free | sed -n 2p | awk '{print $3}')
	MemTot=$(free | sed -n 2p | awk '{print $2}')
	df -Pl | awk '/^\/dev/ {print $1,"~",$2,"~",$3,"~",$4,"~",$5,"~",$6,"~Unknown"}'| tr ' ' '\0' | tr '~' '|' | tr '\n' ';' > /home/yesdb/HealthCheck/DF
	DiskStat=(`cat /home/yesdb/HealthCheck/DF`)
fi

UPTIME=$(uptime)
CPUIDLE=$(iostat | grep -A 1 avg-cpu | grep -v idle | awk {'print $6'})
NTPSTAT=$(ntpstat | grep 'synchronised to NTP server'|wc -l)

#CPU_Idle=$(/usr/bin/mpstat 3 3 | grep Average | awk '{printf "%.2f\n",100-$11 }')
#LoadAvg=$(cat /proc/loadavg | awk '{print $1}')
#IO=$(/usr/bin/sar 3 3 |tail -1| awk '{print $8}')
#tail -10000 $ErrPath | grep -v " server_audit: " | grep "`date '+%Y-%m-%d %H:%M' -d '1 min ago'`" | grep "ERROR" > /home/yesdb/error.log
#ErrorCount=`cat /home/yesdb/error.log | wc -l`
#WebConn=`ps -ef | grep httpd | grep -v grep | wc -l`
#AppConn=0
#/usr/bin/rm /home/yesdb/error.log

#=============================================================================================================================================
echo "`echo $DATE~$UPTIME~$CPUIDLE~$NTPSTAT~$MemTot~$MemUse~$DiskStat`" > $LOGFILE
#=============================================================================================================================================
#                                                                  END
#============================================================================================================================================================


