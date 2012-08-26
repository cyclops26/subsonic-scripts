###############################
#  SubSonic Auto Scan Script  #
#  Written by: Eli Keimig     #
#  Copyright: GPL 2012        #
###############################

#!/bin/bash

## VARIABLES ##
HOST="subsonichost"
PORT="subsonicport"
USER="subsonicusername"
PASS="subsonicpassword"
SESS="/tmp/subsonic.cookie"
CHECK1="/tmp/subsonic.check1"
CHECK2="/tmp/subsonic.check2"


## CHECK FOR OLD FILES AND CLEANUP ##
/bin/rm -f ${SESS}
/bin/rm -f ${CHECK1}
/bin/rm -f ${CHECK2}


## SCRIPT EXECUTION ##
/bin/echo ""
/bin/echo "Getting session..."
CONNECT=`/usr/bin/wget -O /dev/null -o ${CHECK1} --keep-session-cookies --save-cookies ${SESS} --post-data "j_username=${USER}&j_password=${PASS}" --no-check-certificate https://${HOST}:${PORT}/j_acegi_security_check`
/bin/echo "Updating SubSonic..."
UPDATE=`/usr/bin/wget -O /dev/null -o ${CHECK2} --keep-session-cookies --load-cookies ${SESS} --no-check-certificate https://${HOST}:${PORT}/musicFolderSettings.view?scanNow`


## BUILD ERROR ARRAY ##
ERRORCHECK1=`/bin/cat ${CHECK1} | /bin/grep "HTTP request sent, awaiting response..."`
ERRORCHECK2=`/bin/cat ${CHECK2} | /bin/grep "HTTP request sent, awaiting response..."`
ERRORARRAY=`/bin/echo -e "${ERRORCHECK1} \n${ERRORCHECK2}"`
ERRORARRAY=`/bin/echo "${ERRORARRAY}" | /bin/sed -e 's/ /BBBBBBBBBB/g'`


## CLEAR RESULT AND EXIT CODE ##
RESULT=""
ERRORCOUNT=0
EXITCODE=3


## CHECK FOR ERRORS ##
for i in ${ERRORARRAY}
do
  i=`/bin/echo "${i}" | /bin/sed -e 's/BBBBBBBBBB/ /g'`
  if [[ "${i}" != *"302 Found"* && "${i}" != *"200 OK"* ]]; then
    ERRORCOUNT=`echo $((ERRORCOUNT+1))`
  fi
done
if [[ ${ERRORCOUNT} -gt 0 ]]; then
  RESULT="SubSonic failed to update"
  EXITCODE=2
else
  RESULT="SubSonic has been successfully updated"
  EXITCODE=0
fi


## FINAL OUTPUT AND CLEANUP ##
/bin/echo "Cleaning up..."
/bin/rm -f ${SESS}
/bin/rm -f ${CHECK1}
/bin/rm -f ${CHECK2}
/bin/echo "${RESULT}"
/bin/echo ""


## EXIT ##
exit ${EXITCODE}
