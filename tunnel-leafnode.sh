#!/bin/sh
ls
set -e

# make sure to add the relevant token $TOKEN 
ngrok config add-authtoken $TOKEN

# Start the  Ngrok server with the relevant domain name
ngrok http --domain wildcat-powerful-molly.ngrok-free.app 4000 > /dev/null &

echo "RUNNING ON PORT 4000"