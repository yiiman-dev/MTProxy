#!/bin/bash
cd /etc/systemd/system || exit 2
systemctl stop MTProxy

cd /etc/systemd/system || exit 2
systemctl daemon-reload
systemctl start MTProxy
