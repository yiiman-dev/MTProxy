#!/bin/bash
#Variables
#SECRET=""
function GetRandomPort(){
  if ! [ "$INSTALLED_LSOF" == true ]; then
    echo "Installing lsof package. Please wait."
    yum -y -q install lsof
    local RETURN_CODE
    RETURN_CODE=$?
    if [ $RETURN_CODE -ne 0 ]; then
      echo "$(tput setaf 3)Warning!$(tput sgr 0) lsof package did not installed successfully. The randomized port may be in use."
    else
      INSTALLED_LSOF=true
    fi
  fi
  PORT=$((RANDOM % 16383 + 49152))
  if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    GetRandomPort
  fi
}
function GetRandomPortLO(){
  if ! [ "$INSTALLED_LSOF" == true ]; then
    echo "Installing lsof package. Please wait."
    yum -y -q install lsof
    local RETURN_CODE
    RETURN_CODE=$?
    if [ $RETURN_CODE -ne 0 ]; then
      echo "$(tput setaf 3)Warning!$(tput sgr 0) lsof package did not installed successfully. The randomized port may be in use."
    else
      INSTALLED_LSOF=true
    fi
  fi
  PORT_LO=$((RANDOM % 16383 + 49152))
  if lsof -Pi :$PORT_LO -sTCP:LISTEN -t >/dev/null ; then
    GetRandomPortLO
  fi
  if [ $PORT_LO -eq $PORT ]; then
    GetRandomPortLO
  fi
}
function GenerateService(){

  local ARGS_STR

  ARGS_STR="-D tokapps.ir -u nobody -p $PORT_LO -H $PORT "

  for i in "${SECRET_ARY[@]}" # Add secrets
  do
    ARGS_STR+=" -S $i"
  done
  if ! [ -z "$TAG" ]; then
    ARGS_STR+=" -P $TAG "
  fi
#--io-threads 60 --cpu-threads 60 -e SECRET_COUNT=60 --verbosity --multithread
  NEW_CORE=$(($CPU_CORES-1))
  ARGS_STR+=" -M $NEW_CORE $CUSTOM_ARGS --aes-pwd proxy-secret   proxy-multi.conf  "



  SERVICE_STR="[Unit]
Description=MTProxy
After=network.target
[Service]
Type=simple
WorkingDirectory=/opt/MTProxy/objs/bin
ExecStart=/opt/MTProxy/objs/bin/mtproto-proxy $ARGS_STR
Restart=on-failure
[Install]
WantedBy=multi-user.target"
}
#User must run the script as root
if [[ "$EUID" -ne 0 ]]; then
#  echo "Please run this script as root"
  exit 1
fi
regex='^[0-9]+$'
clear
source /opt/MTProxy/objs/bin/mtconfig.conf #Load Configs
SECRET="$(hexdump -vn "16" -e ' /1 "%02x"'  /dev/urandom)"
#echo "OK I created one: $SECRET"

#          echo "OK I created one: $SECRET"


          SECRET=${SECRET:1:31}
          SECRET="$1$SECRET"
#          echo "$SECRET"
      SECRET_ARY+=("$SECRET")
      #Add secret to config
      cd /etc/systemd/system || exit 2
      systemctl stop MTProxy
      rm MTProxy.service
      GenerateService
      echo "$SERVICE_STR" >> MTProxy.service
#      echo "$SERVICE_STR"
      systemctl daemon-reload
      systemctl start MTProxy

      cd /opt/MTProxy/objs/bin/ || exit 2
      SECRET_ARY_STR=${SECRET_ARY[*]}
      sed -i "s/^SECRET_ARY=.*/SECRET_ARY=($SECRET_ARY_STR)/" mtconfig.conf
#      echo "s/^SECRET_ARY=.*/SECRET_ARY=($SECRET_ARY_STR)/"
#      echo "Done"
      PUBLIC_IP="$(curl https://api.ipify.org -sS)"
      CURL_EXIT_STATUS=$?
      if [ $CURL_EXIT_STATUS -ne 0 ]; then
        PUBLIC_IP="YOUR_IP"
      fi
#      echo
#      echo "You can now connect to your server with this secret with this link:"
      SECRET="ee""$SECRET""746f6b617070732e6972"
      echo "$SECRET"
