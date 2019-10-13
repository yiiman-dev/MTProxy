#!/bin/bash

cd /etc/systemd/system || exit 2
#        systemctl daemon-reload
        systemctl stop MTProxy
     cd /opt || exit 2
     cd MTProxy || exit 2
     make --always-make #Build the proxy
        BUILD_STATUS=$? #Check if build was successful
        if [ $BUILD_STATUS -ne 0 ]; then
          echo "$(tput setaf 1)Error:$(tput sgr 0) Build failed with exit code $BUILD_STATUS"
          echo "fix error and compile again"
#          rm -rf /opt/MTProxy
          echo "Done"
          exit 3
        fi
        cd objs/bin || exit 2
        curl -s https://core.telegram.org/getProxySecret -o proxy-secret
        STATUS_SECRET=$?
        if [ $STATUS_SECRET -ne 0 ]; then
          echo "$(tput setaf 1)Error:$(tput sgr 0) Cannot download proxy-secret from Telegram servers."
        fi
        curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf
        STATUS_SECRET=$?
        if [ $STATUS_SECRET -ne 0 ]; then
          echo "$(tput setaf 1)Error:$(tput sgr 0) Cannot download proxy-multi.conf from Telegram servers."
        fi

        cd /etc/systemd/system || exit 2
        systemctl daemon-reload
        systemctl start MTProxy
        systemctl is-active --quiet MTProxy #Check if service is active
        SERVICE_STATUS=$?
        if [ $SERVICE_STATUS -ne 0 ]; then
          echo "$(tput setaf 3)Warning: $(tput sgr 0)Building looks successful but the sevice is not running."
          echo "Check status with \"systemctl status MTProxy\""
        fi
        systemctl enable MTProxy
