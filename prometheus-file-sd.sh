#!/bin/bash

declare -a MANDATORY
MANDATORY=("DOCKERCLOUD_AUTH" "CONTAINERS" "DIR" )
for V in ${MANDATORY[@]}; do
  if [ -z "${!V}" ]; then
    echo -e "Failed to define $V"
    exit 1
  fi
done

ARRAY_CONTAINERS=( $CONTAINERS )
URI="https://cloud.docker.com/api/app/v1"

if [ -z "${FILE_PREFIX}" ]; then
  FILE_PREFIX="file-sd-"
fi

for (( i=0; i<${#ARRAY_CONTAINERS[@]}; i++ ));do
  STACK=$( echo ${ARRAY_CONTAINERS[${i}]} | cut -f1 -d: )
  SERVICE=$( echo ${ARRAY_CONTAINERS[${i}]} | cut -f2 -d: )
  PORT=$( echo ${ARRAY_CONTAINERS[${i}]} | cut -f3 -d: )
  echo "Stack Name: ${STACK} | Service Name: ${SERVICE} | Port Number: ${PORT}"

  API_RESPONSE_STACK=`curl -s -H "Authorization: $DOCKERCLOUD_AUTH" "${URI}/stack/?name=${STACK}"`
  # Get the stack URI for a given stack
  STACK_URI=`echo ${API_RESPONSE_STACK} | jq --raw-output ".objects[] | .resource_uri"`
  echo "Stack URI: ${STACK_URI}"

  # Get the service URI for a given stack and service
  API_RESPONSE_SERVICE=`curl -s -H "Authorization: $DOCKERCLOUD_AUTH" "${URI}/service/?stack=${STACK_URI}&name=${SERVICE}"`

  SERVICE_URI=`echo ${API_RESPONSE_SERVICE} | jq --raw-output ".objects[] | .resource_uri"`
  echo "Service URI: ${SERVICE_URI}"

  API_RESPONSE_CONTAINERS=`curl -s -H "Authorization: $DOCKERCLOUD_AUTH" "${DOCKERCLOUD_REST_HOST}${SERVICE_URI}"`

  # For a given service, write a json object containing all of the containers for a service for a particular stack
  echo -n "[{\"targets\": [" > ${DIR}/${FILE_PREFIX}${SERVICE}.json
  echo ${API_RESPONSE_CONTAINERS} | jq ".link_variables" | grep '[0-9]_ENV_DOCKERCLOUD_CONTAINER_HOSTNAME' | awk {'print $2'} | sed "s/\",/:${PORT}\", /" | tr -d '\n' | sed 's/..$/]}]/' >> ${DIR}/${FILE_PREFIX}${SERVICE}.json
done
