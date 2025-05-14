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

WORKDIR=$1
bearertoken=$(cat $(pwd)/.bearertoken 2>/dev/null)

##################
# Get First Page #
##################

printf "Getting Your Profile Page 1 ... "
respInit=$(curl -s -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' "https://api.ifnapp.com/v4/users/my/content_smiles?limit=100")
echo $respInit | jq .data.content.items[] > $WORKDIR/profiledata.txt 2>/dev/null
next=$(echo $respInit | jq .data.content.paging.cursors.next | tr -d '"')
hasNext=$(echo $respInit | jq .data.content.paging.hasNext | tr -d '"')
status=$(echo $respInit | jq .status);

####################
# HTTP Error Catch #
####################

if [ "$status" != "200" ]; then

  printf "Failed.\n\n  "
  echo $respInit | jq .error_description
  printf "\n"
  exit 1
  
fi

#####################
# Get Pages Til End #
#####################

counter=1
while $hasNext; do

  ((counter++))
  printf "$counter ... "
  respLoop=$(curl -s -H "authorization: Bearer $bearertoken" -H 'ifunny-project-id: iFunny' "https://api.ifnapp.com/v4/users/my/content_smiles?limit=100&next=$next")
  echo $respLoop | jq .data.content.items[] >> $WORKDIR/profiledata.txt
  next=$(echo $respLoop | jq .data.content.paging.cursors.next | tr -d '"')  
  hasNext=$(echo $respLoop | jq .data.content.paging.hasNext | tr -d '"')
  status=$(echo $respLoop | jq .status);

  ####################
  # HTTP Error Catch #
  ####################

  if [ "$status" != "200" ]; then

    printf "Failed.\n\n  "
    echo $respLoop | jq .error_description
    printf "\n"
    exit 1
    
  fi

done

################
# Process Data #
################

printf "Reached the last page!\n\nProcessing data... "
cat $WORKDIR/profiledata.txt | jq .url | tr -d '"' > $WORKDIR/urls.txt # Meme media direct url
cat $WORKDIR/urls.txt | while IFS= read -r url; do
    basename "$url" >> $WORKDIR/filenames.txt # Meme original filename
done
cat $WORKDIR/profiledata.txt | jq .date_create | tr -d '"' > $WORKDIR/dates.txt # Meme date of creation
cat $WORKDIR/profiledata.txt | jq .id | tr -d '"' > $WORKDIR/ids.txt # Meme iFunny UID
cat $WORKDIR/profiledata.txt | jq .is_smiled > $WORKDIR/is_smiled.txt # Did you smile this meme?
cat $WORKDIR/profiledata.txt | jq .is_pinned > $WORKDIR/is_pinned.txt # Is the meme pinned?
printf "Done!\n\n"

exit 0