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

############
# Clean Up #
############

cleanup(){
  if [ "$skipcleanup" != "true" ]; then
    printf "\nCleaning up temporary files... "
    rm $WORKDIR/*.txt 2>/dev/null
    rmdir $WORKDIR 2>/dev/null
    printf "Done!\n\nThank you for using my script!\n-KF\n\n"
  fi
}
trap cleanup EXIT

#########################
# User Input Validation #
#########################

if [ $# -ne 1 ]; then
    printf "\nUsage:\n  ./Unsmile-All-Memes-Of-User.sh 'creator_name'\n\nPurpose:\n  To unsmile all of the selected user's posted memes.\n\nNote:\n  Ensure you are using SINGLE quotes '' and NOT double quotes \"\" to encapsulate the selected username.\n\n"
    skipcleanup="true"
    exit 1
fi

######################
# Token / Risk Check #
######################

$(pwd)/.helpers/Token-Risk-Check.sh
if [ $? -eq 1 ]; then
  skipcleanup="true"
  exit 1
fi

#############
# Variables #
#############

bearertoken=$(cat $(pwd)/.bearertoken 2>/dev/null)
WORKDIR="$(pwd)/.$1_$RANDOM"
mkdir -p $WORKDIR

####################
# Get User Profile #
####################

$(pwd)/.helpers/Get-User-Profile.sh "$1" "$WORKDIR"
if [ $? -eq 1 ]; then
  exit 1
fi

############################
# Unsmile All Not Unsmiled #
############################

printf "Unsmiling All Not Unsmiled Memes...\n\n"
total_lines=$(wc -l < $WORKDIR/ids.txt)
line_num=0
while IFS= read -r id <&3 && IFS= read -r is_unsmiled <&4; do

    ((line_num++))
    echo -n "[${line_num}/${total_lines}] "

    if [[ "$is_unsmiled" = "false" ]]; then
      resp=$(curl -s -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' -X PUT "https://api.ifnapp.com/v4/content/$id/unsmiles")
      status=$(echo $resp | jq .status)

      ####################
      # HTTP Error Catch #
      ####################
      if [ "$status" != "200" ]; then

        ############################
        # Human Verification Check #
        ############################
        if [ "$status" = "403" ]; then
          captcha_url=$(echo $resp | jq .data.captcha_url | tr -d '"')
          printf "403 - Human verification needed\n\nOpen the following link in your web browser and complete the verification:\n\n  $captcha_url\n\nThe verification page may not close or indicate success, but will indicate failure.\nAssume no error after completion means you passed.\nWhen you pass, press any key to continue...\n\n"
          read -n 1 -s -r

          resp=$(curl -s -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' -X PUT "https://api.ifnapp.com/v4/content/$id/unsmiles")
          status=$(echo $resp | jq .status)
          if [ "$status" != "200" ]; then
            printf "Failed.\n\n  "
            echo $resp | jq .error_description
            printf "\n"
            exit 1
          else
            echo "Unsmiled $id"
          fi
        ####################
        # Some Other Error #
        ####################
        else
          printf "Failed.\n\n  "
          echo $resp | jq .error_description
          printf "\n"
          exit 1
        fi
      ###########
      # Success #
      ###########
      else
        echo "Unsmiled $id"
      fi
      
    else
      echo "$id already unsmiled"
    fi

done 3<$WORKDIR/ids.txt 4<$WORKDIR/is_unsmiled.txt