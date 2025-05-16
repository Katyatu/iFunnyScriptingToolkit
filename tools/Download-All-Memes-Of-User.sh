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
    printf "Done!\n\nDownloaded memes can be found at $WORKDIR\n\nThank you for using my script!\n-KF\n\n"
  fi
}
trap cleanup EXIT

#########################
# User Input Validation #
#########################

if [ $# -ne 1 ]; then
    printf "\nUsage:\n  ./Download-All-Memes-Of-User.sh 'creator_name'\n\nPurpose:\n  To download all of the selected user's posted memes to local storage.\n\nNote:\n  Ensure you are using SINGLE quotes '' and NOT double quotes \"\" to encapsulate the selected username.\n\n"
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

if [ -n "$TERMUX_VERSION" ]; then
  if [ -d "$HOME/storage/downloads" ] && [ -r "$HOME/storage/downloads" ]; then
    WORKDIR="$HOME/storage/downloads/iFST/$1"
  else
    skipcleanup="true"
    printf "Please run termux-setup-storage to allow Termux to download to your user Downloads folder.\n\n"
    exit 1
  fi
else
  WORKDIR="$(pwd)/$1"
fi

mkdir -p $WORKDIR

####################
# Get User Profile #
####################

$(pwd)/.helpers/Get-User-Profile.sh "$1" "$WORKDIR"
if [ $? -eq 1 ]; then
  exit 1
fi

##################
# Download Memes #
##################

printf "Downloading memes...\n\n"

aria2c \
  -i "$WORKDIR/urls.txt" \
  -d "$WORKDIR" \
  --max-concurrent-downloads=16 \
  --max-connection-per-server=2 \
  --min-split-size=1M \
  --split=16 \
  --max-tries=3 \
  --retry-wait=2 \
  --timeout=30 \
  --auto-file-renaming=false \
  --user-agent="Mozilla/5.0" \
  --quiet \
  --on-download-complete="./.helpers/Aria2-On-Complete.sh" \
  --on-download-error="./.helpers/Aria2-On-Error.sh"

#############################
# Embed Dates / Crop Images #
#############################

printf "\nEmbedding original dates and cropping out the watermark...\n\n"
total_lines=$(wc -l < $WORKDIR/filenames.txt)
line_num=0
while IFS= read -r filename <&3 && IFS= read -r epoch <&4; do

    ((line_num++))

    if [ "$(exiftool -Description -s3 $WORKDIR/$userid/$filename)" = "iFST" ]; then
      echo "[${line_num}/${total_lines}] $filename | Already processed, skipping"
      continue
    fi
    
    # Convert epoch to exiftool-compatible format (YYYY:MM:DD HH:MM:SS)
    datetime=$(date -d "@$epoch" -u +"%Y:%m:%d %H:%M:%S")
    
    echo "[${line_num}/${total_lines}] $filename | $datetime"

    # Crop bottom 20px off images
    if file --mime-type "$WORKDIR/$userid/$filename" | grep -qE 'image/(jpeg|png|bmp|tiff|jpg)'; then
    
        read -r width height < <(identify -format "%w %h" "$WORKDIR/$filename")
        new_height=$((height - 20))
        magick "$WORKDIR/$filename" -crop "${width}x${new_height}+0+0" "$WORKDIR/$filename"
        
    fi
    
    # Embed metadata
    exiftool -q -overwrite_original "-FileModifyDate=$datetime" "-DateTimeOriginal=$datetime" "-CreateDate=$datetime" "-DateCreated=$datetime" "-Description=iFST" "$WORKDIR/$filename"

done 3<$WORKDIR/filenames.txt 4<$WORKDIR/dates.txt
