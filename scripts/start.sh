#!/bin/bash

echo "Environment info: "
echo "hostname: `hostname`"
echo "ip address: `hostname -i`"
echo "TZ: ${TZ}"
echo "date: `date`"
echo "operating system: `cat /etc/issue`"
echo "kernel: `uname -a`"
echo "bitcoind version: `bitcoind --version`"

echo "Hello, from bitcoind-docker container"

# Docker convention (of several) to keep the container from exiting if services don't start or there's nothing for it to do next. 
tail -f /dev/null
 
