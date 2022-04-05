#=============================================================================================================================================
# File Name     : /home/yesdb/ConfigManagement.sh
# Author        : Seetha Ram.M
# Description   : Capture Installed RPM Details
#=============================================================================================================================================
#!/bin/bash
DATE=`date +%F' '%T`
#rpm -q -a --queryformat "$DATE~%{INSTALLTIME}\t%{INSTALLTIME:day}|%{BUILDTIME:day}|%-30{NAME}|\t%15{VERSION}|%-7{RELEASE}|\t%{arch}|%25{VENDOR}|\n" | cut --fields="2-" > /home/yesdb/ConfigManagement.out
rpm -q -a --queryformat "%{INSTALLTIME:day}|%{BUILDTIME:day}|%{NAME}|%{VERSION}|%{RELEASE}|%{arch}|%{VENDOR}|`date +%F' '%T`\n" > /home/yesdb/ConfigManagement.csv
#=============================================================================================================================================
#                                                                  END
#=============================================================================================================================================