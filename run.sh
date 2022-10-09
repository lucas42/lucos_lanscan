#!/bin/sh
set -e
printenv > .env
[ -p /var/log/new.log ] || mkfifo /var/log/new.log

cat <> /var/log/new.log