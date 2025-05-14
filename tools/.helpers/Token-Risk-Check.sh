#!/bin/bash

# Copyright © 2025 Katyatu - https://github.com/katyatu
# Licensed under CC BY-NC-ND 4.0 (https://creativecommons.org/licenses/by-nc-nd/4.0/)

###########
# Credits #
###########

##########################################
# © Katyatu - https://github.com/katyatu #
#                                        #
#    DO NOT TRUST ANY OTHER SOURCES!     #
##########################################

######################
# Bearer Token Check #
######################

bearertoken=$(cat $(pwd)/.bearertoken 2>/dev/null)

if [ -z "$bearertoken" ]; then
  printf "\nNo Bearer Token found. Please run ./Get-Your-iF-Bearer-Token.sh first in order to authenticate API requests with iFunny servers.\n\n"
  exit 1
else
  printf "\nChecking Bearer Token... "

  accountresp=$(curl -s -i -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' https://api.ifnapp.com/v4/account)
  status=$(echo "$accountresp" | grep "status" | jq .status)

  if [ "$status" != "200" ]; then
    printf "Failed.\n\n  "
    echo "$accountresp" | grep "status" | jq .error_description
    printf "\n"
    exit 1
  fi

  printf "Authentic!\n"

fi

###################
# Risk Assessment #
###################

# Level: 1 | Reason: Third Party Country | Sensitive Content: Blocked
# Level: 2 | Reason: Action              | Sensitive Content: Not Blocked
# Level: 3 | Reason: Content             | Sensitive Content: Not Blocked

printf "\nDetermining if iFunny's server will withhold 'sensitive' content..."

risklevel=$(echo "$accountresp" | grep "inst:" | sed 's/inst: //g' | jq .risk.level)

if [ "$risklevel" = "1" ]; then 
  printf " it will.\n\nThe iFunny servers currently have you at risk level $risklevel, meaning, 'sensitive' content is being filtered out of the API responses.\nThe script will function as normal, but any memes that have the data value 'is_unsafe=true' will not be included, so expect missing content.\nRisk level is entirely server-sided, factors influencing what level you are at is unknown.\nFactors like region location, time since bearer token creation, smiled content, content viewed, etc. could be of influence.\nTry using a VPN and connecting to different countries, using the 'Smile-All-Memes-Of-User.sh', or waiting a few hours.\nWhen your risk level changes to include 'sensitive' content, you won't see this message.\n\n"
else
  printf " 'sensitive' content will be included!\n\n"
fi

exit 0
