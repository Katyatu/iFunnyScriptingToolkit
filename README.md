# $\color{#FFCC00}{iFunny\ Scripting\ Toolkit}$

A collection of BASH scripts that interact with the iFunny servers' API, allowing for automation of certain tasks.

During my cybersecurity studies, I had forgotten to turn off some tools when I went on break, and ended up logging the HTTP/S traffic of the iFunny app. After a few hours of studying the traffic and messing around with the various endpoints of the iFunny servers, I managed to churn out some scripts that can be proven useful for automating painfully repetitive tasks.

Ethically speaking, I'll only release non-malicious scripts, like auto smiling someone's entire profile, auto self-deleting all the memes you posted, etc. Potentially malicious scripts, like comment scripting, will never be made as we've all dealt with _certain_ comment bots over the years. I won't be responsible for whatever blight hits iFunny next.

Before using what I have offered here, at the very least, read up on how to interact with the Linux Command Line Interface. It will be assumed that you have basic understanding of CLI usage. Be aware that these scripts are built for Linux based operating systems, ie. Debian-based distros and Android. I have no plans on porting to Windows/Mac, or creating an app.

## Disclaimers

1. Do **NOT** use any scripts obtained outside of this repository.

2. This is **THE** only official source for my toolkit.

3. All **OTHER** sources are to be assumed **MALICIOUS**.

4. Use common sense, and use **RESPONSIBLY**.

5. I am **NOT** liable for the actions of others.

6. I am **NOT** affiliated with any iFunny accounts.

## Table of Contents

- [Setup for Android](#setup-for-android)
  - [1. Download and Install "Termux"](#1-download-and-install-termux)
  - [2. Setup Termux](#2-setup-termux)
  - [3. Prep The Toolkit](#3-prep-the-toolkit)
  - [4. Get Your "Bearer Token"](#4-get-your-bearer-token)
- [Setup For Linux](#setup-for-linux)
  - [1. Install Dependencies](#1-install-dependencies)
  - [2. Clone This Repo](#2-clone-this-repo)
  - [3. Make All Scripts Executable](#3-make-all-scripts-executable)
  - [4. Get Your "Bearer Token"](#4-get-your-bearer-token-1)
- [Usage](#usage)
  - [Reminder](#reminder)
  - [Available Scripts](#available-scripts)
  - [Examples](#examples)
- [Notes](#notes)
- [License](#license)

## Setup for Android

Since Android is based on Linux, these scripts can be executed on your mobile device without needing a Linux PC. The following steps will guide you through how to set things up.

### 1. Download and Install "Termux"

- "Termux is an Android terminal application and Linux environment."

  - https://github.com/termux/termux-app

- You will need to start with grabbing the latest APK of Termux from their official repo, and installing it. The Play Store has Termux on it, but it is a very outdated version. My scripts are tested with the APK from their official repo.

  - Pick the "universal.apk" version from the "Assets" section at https://github.com/termux/termux-app/releases/latest and install it.

### 2. Setup Termux

- First, you will need to make sure everything is up to date, run:

  ```bash
  pkg update && pkg upgrade -y && pkg clean
  ```

- Next, you will need to allow Termux access to your local storage. This is needed for you to transfer any downloaded memes out of Termux's private storage and into your user storage for viewing. Run the following command and allow the storage access permission when it pops up:

  ```bash
  termux-setup-storage
  ```

- Finally, you need to install some tool dependencies the scripts need in order to function:

  ```bash
  pkg install -y git jq imagemagick exiftool aria2 file
  ```

  - git - to download this repo
  - jq - to parse JSON objects
  - imagemagick - to crop off the meme's watermark
  - exiftool - to embed the creation date metadata for sorting memes by date
  - aria2 - to perform parallel meme downloads
  - file - to determine meme file type

### 3. Prep The Toolkit

- Clone this repo:

  ```bash
  git clone https://github.com/Katyatu/iFunnyScriptingToolkit
  ```

- Move into the toolkit:

  ```bash
  cd iFunnyScriptingToolkit
  ```

- Make all scripts executable:

  ```bash
  chmod -R u+x ./
  ```

- Move into the "tools" directory:
  ```bash
  cd tools
  ```

### 4. Get Your "Bearer Token"

- In order for the scripts' API requests to go through, it needs authentication.

- When you log into your account on the iFunny app, the iFunny servers return a "Bearer Token" that serves as identification.

- Every single interaction you perform in the app, ie. smiling, subbing, etc., all include that token in the API request, so the servers know which account to perform the requested action with.

- I made a script that mimics the action of logging in via iFunny app, outside of the app, capturing the returned Bearer Token for the other scripts to use as authentication.

- Be aware, you will need to provide your iFunny account email and password to get this token.

- Start by viewing the "Get-Your-iF-Bearer-Token.sh" script code with your own eyes:

  ```bash
  cat ./Get-Your-iF-Bearer-Token.sh
  ```

  - Bonus points if you feed the code into an "AI" like Grok and ask it to look for anything malicious.

- If you are satisfied, execute the script like so:

  ```bash
  ./Get-Your-iF-Bearer-Token.sh 'ifunny@email.com' 'ifunnyPass'
  ```

  - Please note the SINGLE quotes surrounding the arguments. Do NOT use DOUBLE quotes as the command line will interpret some symbols as console specific actions.

- Read the script output, I tried to make it as verbose and catch as many errors as possible. You will know if it failed or succeeded.
  - If it fails, read the output and act accordingly.
  - If it succeeds, a `.bearertoken` file will be created containing your token.
- If you made it this point, you are ready to start [using the toolkit](#usage)!

## Setup For Linux

Skip this section if you're using Android.

This section will assume you are familiar with a Debian-based environment, so instructions will be brief and to the point. Read the Android section if you want extra step details.

### 1. Install Dependencies

```bash
sudo apt install git jq imagemagick exiftool aria2 file
```

### 2. Clone This Repo

```bash
git clone https://github.com/Katyatu/iFunnyScriptingToolkit
cd iFunnyScriptingToolkit
```

### 3. Make All Scripts Executable

```bash
chmod -R u+x ./
```

### 4. Get Your "Bearer Token"

```bash
cd tools
./Get-Your-iF-Bearer-Token.sh 'ifunny@email.com' 'ifunnyPass'
```

## Usage

### Reminder

Make sure you are in the "tools" folder of "iFunnyScriptingToolkit", and that you surround your arguments with SINGLE quotes.

### Available Scripts

<hr/>

#### Get Your iFunny Account Bearer Token

```bash
./Get-Your-iF-Bearer-Token.sh 'arg1' 'arg2'
```

- Gets your iFunny account's Bearer Token. Required for the below scripts to be authenticated with the API.
  - _arg1_: Your iFunny account email
  - _arg2_: Your iFunny account password

<hr/>

#### Download All Memes Of A Specific User

```bash
./Download-All-Memes-Of-User.sh 'arg1'
```

- Downloads every meme the selected user has posted.
  - _arg1_: Name of user
- Note: If using Termux on Android, in order to move the download folder out of Termux and into your device's general downloads folder, run the following command after the script finishes:
  - ```bash
    mv 'arg1' ~/storage/downloads
    ```

<hr/>

#### Smile All Memes Of A Specific User (neutral/unsmiled → smiled)

```bash
./Smile-All-Memes-Of-User.sh 'arg1'
```

- Smiles every meme the selected user has posted.
  - _arg1_: Name of user

<hr/>

#### Desmile All Memes Of A Specific User (smiled → neutral)

```bash
./Desmile-All-Memes-Of-User.sh 'arg1'
```

- Desmiles every meme the selected user has posted (not to be confused with *un*smile).
  - _arg1_: Name of user

<hr/>

#### Unsmile All Memes Of A Specific User (neutral/smiled → unsmiled)

```bash
./Unsmile-All-Memes-Of-User.sh 'arg1'
```

- Unsmiles every meme the selected user has posted.
  - _arg1_: Name of user

<hr/>

#### Deunsmile All Memes Of A Specific User (unsmiled → neutral)

```bash
./Deunsmile-All-Memes-Of-User.sh 'arg1'
```

- Deunsmiles every meme the selected user has posted.
  - _arg1_: Name of user

<hr/>

#### Desmile All Memes You Have Smiled

```bash
./Clear-My-Smiled-Memes.sh
```

- Desmiles every meme in the smiles category of your profile.

<hr/>

#### Delete All Of Your Unpinned Memes

```bash
./Delete-All-Of-Your-Unpinned-Memes.sh
```

- Deletes every unpinned meme you have ever posted.
- Irreversible, requires explicit permission, impossible to accidentally execute.

<hr/>

### Examples

```bash
./Smile-All-Memes-Of-User.sh 'cirke'
```

```bash
./Unsmile-All-Memes-Of-User.sh 'ColDirtybastard'
```

## Notes

- Treat your Bearer Token like an API key. Anyone that has it has control of your iFunny account. Change your password if you believe your token is compromised, this will invalidate all existing tokens.

- The iFunny servers have rate limits. Only execute one script at a time. Executing more than one script will lead to repeated human verification tests, thus wasting a lot of time. Go slow, be patient.

- The content delivery network iFunny uses seems to either be rate limitless, or has a high tolerance. You might be able to get away with running multiple instances of the downloader script, but don't overdo it.

- Check back here from time to time for updates and additional scripts.

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/), and is intended for personal, non-commercial use only.

**You Are Allowed To**:

- Copy and redistribute _unmodified_ code

**You Are NOT Allowed To**:

- Redistribute _modified_ code
- Use un/modified code for commercial use
