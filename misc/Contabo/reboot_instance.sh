#!/usr/bin/env bash

##Requirements: cntb bash coreutils curl findutils jq moreutils

##Config: https://my.contabo.com/api/details
# export CONTABO_CLIENT_ID='id'
# export CONTABO_CLIENT_SECRET='secret'
# export CONTABO_API_USERNAME='email'
# export CONTABO_API_PASSWORD='api_password_NOT_account_password'
# export INSTANCE_HOST_NUMBER="Host Number from: https://my.contabo.com/vps/0#"

##Usage:
# bash <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Arsenal/main/misc/Contabo/reboot_instance.sh")
# bash <(curl -qfsSL "https://pub.ajam.dev/repos/Azathothas/Arsenal/misc/Contabo/reboot_instance.sh")

#----------------------------------------------------------------------------#
##Sanity Checks
   SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
   USER_AGENT="$(curl -qfsSL 'https://pub.ajam.dev/repos/Azathothas/Wordlists/Misc/User-Agents/ua_chrome_macos_latest.txt')" && export USER_AGENT="${USER_AGENT}"
 #Curl
   if ! command -v curl &> /dev/null; then
     echo -e "\n[-] FATAL: Install Curl (https://bin.ajam.dev/$(uname -m)/curl)\n"
   exit 1
   fi
 #Get Bin  
   if command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
     sudo curl -A "${USER_AGENT}" -qfsSL "https://bin.ajam.dev/$(uname -m)/cntb" -o "/usr/local/bin/cntb" && sudo chmod +x "/usr/local/bin/cntb"
     sudo curl -A "${USER_AGENT}" -qfsSL "https://bin.ajam.dev/$(uname -m)/ipinfo" -o "/usr/local/bin/ipinfo" && sudo chmod +x "/usr/local/bin/ipinfo"
     sudo curl -A "${USER_AGENT}" -qfsSL "https://bin.ajam.dev/$(uname -m)/jq" -o "/usr/local/bin/jq" && sudo chmod +x "/usr/local/bin/jq"
   else
     curl -A "${USER_AGENT}" -qfsSL "https://bin.ajam.dev/$(uname -m)/cntb" -o "${SYSTMP}/cntb" && chmod +x "${SYSTMP}/cntb"
     curl -A "${USER_AGENT}" -qfsSL "https://bin.ajam.dev/$(uname -m)/ipinfo" -o "${SYSTMP}/ipinfo" && chmod +x "${SYSTMP}/ipinfo"
     curl -A "${USER_AGENT}" -qfsSL "https://bin.ajam.dev/$(uname -m)/jq" -o "${SYSTMP}/jq" && chmod +x "${SYSTMP}/jq"
     export PATH="${PATH}:${SYSTMP}"
   fi
 #CONTABO_CLIENT_ID
   if [ -z "$CONTABO_CLIENT_ID" ] || [ -z "${CONTABO_CLIENT_ID+x}" ]; then
     echo -e "\n[-] CONTABO_CLIENT_ID isn't Exported: https://my.contabo.com/api/details\n"
    exit 1
   else
     export CONTABO_CLIENT_ID="$(echo ${CONTABO_CLIENT_ID} | sed "s/['\"]//g" | tr -d '[:space:]')" && export CONTABO_CLIENT_ID="${CONTABO_CLIENT_ID}"
   fi
 #CONTABO_CLIENT_SECRET
   if [ -z "$CONTABO_CLIENT_SECRET" ] || [ -z "${CONTABO_CLIENT_SECRET+x}" ]; then
     echo -e "\n[-] CONTABO_CLIENT_SECRET isn't Exported: https://my.contabo.com/api/details\n"
    exit 1
   else
     export CONTABO_CLIENT_SECRET="$(echo ${CONTABO_CLIENT_SECRET} | sed "s/['\"]//g" | tr -d '[:space:]')" && export CONTABO_CLIENT_SECRET="${CONTABO_CLIENT_SECRET}"
   fi
 #CONTABO_API_USERNAME
   if [ -z "$CONTABO_API_USERNAME" ] || [ -z "${CONTABO_API_USERNAME+x}" ]; then
     echo -e "\n[-] CONTABO_API_USERNAME isn't Exported: https://my.contabo.com/api/details\n"
    exit 1
   else
     export CONTABO_API_USERNAME="$(echo ${CONTABO_API_USERNAME} | sed "s/['\"]//g" | tr -d '[:space:]')" && export CONTABO_API_USERNAME="${CONTABO_API_USERNAME}"
   fi
 #CONTABO_API_PASSWORD
   if [ -z "$CONTABO_API_PASSWORD" ] || [ -z "${CONTABO_API_PASSWORD+x}" ]; then
     echo -e "\n[-] CONTABO_API_PASSWORD isn't Exported: https://my.contabo.com/api/details\n"
    exit 1
   else
     export CONTABO_API_PASSWORD="$(echo ${CONTABO_API_PASSWORD} | sed "s/['\"]//g" | tr -d '[:space:]')" && export CONTABO_API_PASSWORD="${CONTABO_API_PASSWORD}"
   fi
 #INSTANCE_HOST_NUMBER
   if [ -z "$INSTANCE_HOST_NUMBER" ] || [ -z "${INSTANCE_HOST_NUMBER+x}" ]; then
     echo -e "\n[-] INSTANCE_HOST_NUMBER isn't Exported: https://my.contabo.com/api/details\n"
    exit 1
   else
     export INSTANCE_HOST_NUMBER="$(echo ${INSTANCE_HOST_NUMBER} | sed "s/['\"]//g" | tr -d '[:space:]')" && export INSTANCE_HOST_NUMBER="${INSTANCE_HOST_NUMBER}"
   fi
#----------------------------------------------------------------------------#

#----------------------------------------------------------------------------#
#Set config [ "$HOME/.cntb.yaml" || "/etc/cntb/.cntb.yaml" ]
 cntb config set-credentials --oauth2-clientid="${CONTABO_CLIENT_ID}" --oauth2-client-secret="${CONTABO_CLIENT_SECRET}" --oauth2-user="${CONTABO_API_USERNAME}" --oauth2-password="${CONTABO_API_PASSWORD}" --debug="info"
#List
 cntb get instances
#Get Instance_ID
 CONTABO_INSTANCE_ID="$(cntb get instances --output="json" | jq --arg HN "$HOST_NUMBER" '.[] | select(.vHostNumber == ($HN | tonumber))' | jq -r '.instanceId')" && export CONTABO_INSTANCE_ID="${CONTABO_INSTANCE_ID}"
 CONTABO_INSTANCE_IP="$(cntb get instances --output="json" | jq --arg HN "$HOST_NUMBER" '.[] | select(.vHostNumber == ($HN | tonumber))' | jq -r '.ipv4')" && export CONTABO_INSTANCE_IP="${CONTABO_INSTANCE_IP}"
#Reboot
 echo -e "\n[+] Stopping... ${CONTABO_INSTANCE_ID} (${INSTANCE_HOST_NUMBER})"
 cntb stop instance "${CONTABO_INSTANCE_ID}" && sleep 10
 cntb get instance "${CONTABO_INSTANCE_ID}"
 echo -e "\n[+] Starting... ${CONTABO_INSTANCE_ID} (${INSTANCE_HOST_NUMBER})"
 cntb start instance "${CONTABO_INSTANCE_ID}" && sleep 10
 cntb get instance "${CONTABO_INSTANCE_ID}"
 cntb get instance "${CONTABO_INSTANCE_ID}" --output="yaml"
#Get IP Info
 #curl -A "${USER_AGENT}" -H "Accept: application/json" -qfsSL "https://ipinfo.io/${CONTABO_INSTANCE_IP}/json" | jq . ; echo
 ipinfo "${CONTABO_INSTANCE_IP}" --pretty 2>/dev/null
#END
unset CONTABO_INSTANCE_ID
rm -rf "$HOME/.cntb.yaml" ; sudo rm -rf "/etc/cntb/.cntb.yaml" 2>/dev/null
#EOF
#----------------------------------------------------------------------------#
