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

cd "$(dirname "$0")"

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

###########################
# User Confirmation Check #
###########################

read -p $'\nYou are about to delete EVERY unpinned meme you have posted to your profile.\n\nAre you ABSOLUTELY SURE you want to be doing this?\n\nThere is NO POSSIBLE WAY to recover deleted memes.\n\nTo continue, you must explicitly type \"Yes, I am absolutely sure I want to delete all of my unpinned posted memes.\"\n\n' answer
if [ "$answer" != "Yes, I am absolutely sure I want to delete all of my unpinned posted memes." ] ; then
  printf "\nExplicit permission not given, halting procedure. No changes were made.\n"
  exit 1
else
  printf "\nExplicit permission given, proceeding with purging all unpinned memes...\n"
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

accountid=$(cat $(pwd)/.accountid 2>/dev/null)
bearertoken=$(cat $(pwd)/.bearertoken 2>/dev/null)
WORKDIR="$(pwd)/.me_$RANDOM"
mkdir -p $WORKDIR

####################
# Get Your Profile #
####################

$(pwd)/.helpers/Get-User-Profile.sh "$accountid" "$WORKDIR"
if [ $? -eq 1 ]; then
  exit 1
fi

#########################
# Deleting All Unpinned #
#########################

printf "Deleting all of your unpinned memes...\n\n"
total_lines=$(wc -l < $WORKDIR/ids.txt)
line_num=0
while IFS= read -r id <&3 && IFS= read -r is_pinned <&4; do

    ((line_num++))
    echo -n "[${line_num}/${total_lines}] "

    if [[ "$is_pinned" = "false" ]]; then
      resp=$(curl -s -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' -X DELETE https://api.ifnapp.com/v4/content/$id)
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

          resp=$(curl -s -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' -X DELETE https://api.ifnapp.com/v4/content/$id)
          status=$(echo $resp | jq .status)
          if [ "$status" != "200" ]; then
            printf "Failed.\n\n  "
            echo $resp | jq .error_description
            printf "\n"
            exit 1
          else
            echo "Deleted $id"
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
        echo "Deleted $id"
      fi
      
    else
      echo "$id is pinned, skipping."
    fi

done 3<$WORKDIR/ids.txt 4<$WORKDIR/is_pinned.txt
