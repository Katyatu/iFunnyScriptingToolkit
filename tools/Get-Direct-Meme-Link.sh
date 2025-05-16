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

#########################
# User Input Validation #
#########################

if [ $# -ne 1 ]; then
    printf "\nUsage:\n  ./Get-Direct-Meme-Link.sh 'https://ifunny.co/<picture|gif|video>/123456789/?s=cl'\n\nPurpose:\n  To get the direct media link of the selected meme URL.\n\nNote:\n  Ensure you are using SINGLE quotes '' and NOT double quotes \"\" to encapsulate the selected username.\n\n"
    exit 1
fi

if [[ $1 != https://ifunny.co/video/* && $1 != https://ifunny.co/picture/* && $1 != https://ifunny.co/gif/* ]]; then
    printf "\nThe meme URL must be one of the following:\n\nPicture: 'https://ifunny.co/picture/'\n    Gif: 'https://ifunny.co/gif/'\n  Video: 'https://ifunny.co/video/'\n\n"
    exit 1
fi

###############################
# Parse Direct Link From HTML #
###############################

printf "\nGetting direct media link for '$1'... "

html=$(curl -s --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36" "$1" | grep 'window.__INITIAL_STATE__=' | cut -c 38- | rev | cut -c 132- | rev);
type=$(echo $html | jq .seo.type | tr -d '"')
if [[ -z "$html" || "$type" = "null" ]]; then
  printf "Failed.\n\nDouble check the link you provided, it should look like:\n\nPicture: 'https://ifunny.co/picture/123456789?s=cl'\n    Gif: 'https://ifunny.co/gif/123456789?s=cl'\n  Video: 'https://ifunny.co/video/123456789?s=cl'\n\n"
  exit 1
fi

if [ "$type" = "video.other" ]; then
  direct=$(echo $html | jq .seo.video | tr -d '"') # Video
elif [[ "$1" =~ "gif" ]]; then
  direct=$(echo $html | jq .feed.items[0].url | tr -d '"') # GIF
else
  direct=$(echo "https://imageproxy.ifunny.co/crop:x-20/images/$(basename $(echo $html | jq .seo.image | tr -d '"'))") # Image
fi

printf "Done!\n\n$direct\n\nThank you for using my script!\n-KF\n\n"