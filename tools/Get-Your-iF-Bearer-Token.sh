#!/bin/bash

# Copyright © 2025 Katyatu - https://github.com/katyatu
# Licensed under CC BY-NC-ND 4.0 (https://creativecommons.org/licenses/by-nc-nd/4.0/)

###########
# Credits #
###########

echo "##########################################"
echo "# © Katyatu - https://github.com/katyatu #"
echo "#                                        #"
echo "#    DO NOT TRUST ANY OTHER SOURCES!     #"
echo "##########################################"

#########################
# User Input Validation #
#########################

if [ $# -ne 2 ]; then
    printf "\nUsage:\n  ./Get-Your-iF-Bearer-Token.sh 'ifunny@email.com' 'ifunnypassword'\n\nPurpose:\n  Mimics the process of logging into your iFunny account in-app.\n  Successful login returns a 'Bearer' token that is saved locally and used to authenticate your API interactions with iFunny servers.\n  It serves to connect your API interactions with your iFunny account, allowing you to perform actions like smiling content of your subscriptions.\n\nNote:\n  Ensure you are using SINGLE quotes '' and NOT double quotes \"\" to encapsulate your email/pass.\n\n"
    exit 1
fi

#############
# Functions #
#############

# Encodes your login details to satisfy HTTP request formatting
urlencode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

###################
# Login Variables #
###################

# The login details you provided
email=$1
password=$2

# The encoded login details used in HTTP requests
emailencoded="$(urlencode $email)"
passwordencoded="$(urlencode $password)"

#################
# Login Attempt #
#################

# Sends a login request with your encoded login details
printf "\nAttempting login with provided credentials... "
resp=$(curl -s -H 'ifunny-project-id: iFunny' -H 'authorization: Basic MzYzMzM4NjUzNDYyMzMzNjY1NjYzNzY1MzQzNjYzNjVfTXNPSUozOVEyODoxZTg1Njg5MmY0NGVhYzFmMTFhNjc3NDM4OGIwMTEyYmM3MjBmYTQ4' -X POST https://api.ifnapp.com/v4/oauth2/token -d "grant_type=password&client_id=&username=$emailencoded&password=$passwordencoded");
status=$(echo $resp | jq .status);
accesstoken=$(echo $resp | jq .access_token);

############################
# Human Verification Check #
############################

# In the event the iFunny servers require human verification, a captcha link is returned. Manual completion is required before trying again.
if [ "$status" = "403" ]; then

  captcha_url=$(echo $resp | jq .data.captcha_url | tr -d '"')
  printf "403 - Human verification needed\n\nOpen the following link in your web browser and complete the verification:\n\n  $captcha_url\n\nThe verification page may not close or indicate success, but will indicate failure.\nAssume no error after completion means you passed.\nWhen you pass, press any key to continue...\n\n"
  read -n 1 -s -r

  printf "Attemping login with provided credentials again... "
  resp=$(curl -s -H 'ifunny-project-id: iFunny' -H 'authorization: Basic MzYzMzM4NjUzNDYyMzMzNjY1NjYzNzY1MzQzNjYzNjVfTXNPSUozOVEyODoxZTg1Njg5MmY0NGVhYzFmMTFhNjc3NDM4OGIwMTEyYmM3MjBmYTQ4' -X POST https://api.ifnapp.com/v4/oauth2/token -d "grant_type=password&client_id=&username=$emailencoded&password=$passwordencoded");
  accesstoken=$(echo $resp | jq .access_token | tr -d '"')

fi

#####################
# Token Error Catch #
#####################

if [ "$accesstoken" = "null" ]; then

  printf "Failed.\n\n  "
  echo $resp | jq .error_description
  printf "\n"
  exit 1

fi

#################
# Testing Token #
#################

printf "Success!\n\nTesting your new bearer token by fetching your account details... "
resp=$(curl -s -H "authorization: Bearer $accesstoken" -H 'ifunny-project-id: iFunny' -X GET https://api.ifnapp.com/v4/account)
status=$(echo $resp | jq .status)

if [ "$status" != "200" ]; then

  printf "Failed.\n\n  "
  echo $resp | jq .error_description
  printf "\n"
  exit 1

fi

accountName=$(echo $resp | jq .data.nick | tr -d '"')
accountURL=$(echo $resp | jq .data.web_url | tr -d '"')
accountID=$(echo $resp | jq .data.id | tr -d '"')
printf "Success!\n\nName: $accountName\nURL: $accountURL\nID: $accountID\n\n"
echo $accountID > "$(pwd)/.accountid"

####################
# Get Bearer Token #
####################

echo "$accesstoken" | tr -d '"' > "$(pwd)/.bearertoken"
printf "##########\n\nYour iFunny Bearer Token:\n\n  $accesstoken\n\nBearer token is saved to:\n\n  "$(pwd)"/.bearertoken\n\n##########\n\nLike with any other kind of API key, DO NOT SHARE IT!\nChange your iFunny account password if you believe your token is compromised.\n\nThis token should be valid for '315360000' seconds (10 yrs), but can be invalidated for any reason.\nRun this script again if you start getting errors to get a new token.\n\nThank you for using my script!\n-KF\n\n"