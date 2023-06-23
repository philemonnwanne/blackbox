# Script compatible with both zsh and bash shells
#!/usr/bin/env bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="connect.sh"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

MONGO_LOCAL_URL="mongodb://127.0.0.1:27017"

if [ CONNECTION_URL = ${MONGO_LOCAL_URL} ]; then
  echo "connection url is valid"
else
  CONNECTION_URL=${MONGO_PROD_URL}
  echo "Switched connection url for temp shell script access!"
fi

if [ "$1" = "prod" ]; then
  URL=${MONGO_PROD_URL}
  echo "Connecting to the production DATABASE!!!"
  psql $URL && echo "Bye Bye from the production DATABASE!!!"
else
  URL=${MONGO_LOCAL_URL}
  echo "Connecting to the development DATABASE!!!"
  psql $URL && echo "Bye Bye from the development DATABASE!!!"
fi