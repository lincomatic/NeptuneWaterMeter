#!/bin/bash

if [ -z "$METERID" ]; then
  echo "METERID not set, launching in debug mode"
  echo "If you don't know your Meter's ID, you'll need to figure it out manually"
  echo "Easiest way is to go outside and read your meter, then match it to a meter id in the logs"
  echo "Note: It may take a several minutes to read all the nearby meters"

  rtl_tcp &> /dev/null &
  sleep 10 #Let rtl_tcp startup and open a port

  rtlamr -msgtype=r900
  exit 0
fi

# Kill this script (and restart the container) if we haven't seen an update in 30 minutes
# Nasty issue probably related to a memory leak, but this works really well, so not changing it
./watchdog.sh 30 updated.log &

while true; do
  echo start reading: `date`
  # Suppress the very verbose output of rtl_tcp and background the process
  rtl_tcp &> /dev/null &
  rtl_tcp_pid=$! # Save the pid for murder later
  sleep 10 #Let rtl_tcp startup and open a port

  json=$(rtlamr -msgtype=r900 -filterid=$METERID -single=true -format=json)
  echo "Meter info: $json"

  consumption=$(echo $json | python -c "import json,sys;obj=json.load(sys.stdin);print float(obj[\"Message\"][\"Consumption\"])/10.0")
  echo "Current consumption: $consumption gal"

  # Replace with your custom logging code
  if [ ! -z "$CURL_API" ]; then
    echo "Logging to custom API"
    CURL="curl -i -XPOST $URI/api/v2/write?bucket=h2o --data-binary 'h2o,id=$METERID gal=$consumption'"
    echo $CURL
    eval $CURL
  fi

  kill $rtl_tcp_pid # rtl_tcp has a memory leak and hangs after frequent use, restarts required - https://github.com/bemasher/rtlamr/issues/49

  # Let the watchdog know we've done another cycle
  #echo $json >updated.log
  if [ ! -z `echo $json | wc -w` ]; then touch updated.log; fi
  # wait until next read
  # 60*15=900 do @ 0,15,30,45 on the hour
  sleep $((900 - $(date +%s) % 900))
done

