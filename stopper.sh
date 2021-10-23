#!/bin/bash

DOCKER_CONTAINER_LIST=$(docker ps --format '{{.Names}}')
CURRENT_TIMESTAMP=$(date +%s)

for container in $DOCKER_CONTAINER_LIST
do
        echo "Checking if container $container got expire label"
        EXPIRE_LABEL_VALUE=$(docker inspect --format '{{ index .Config.Labels "docker.container.expire"}}' $container)

        if [ -z "$EXPIRE_LABEL_VALUE" ]
          then
            continue
        fi

        STARTED_AT=$(docker inspect --format='{{.State.StartedAt}}' $container)
        STARTED_AT_TIMESTAMP=$(date -d"$STARTED_AT" +%s)
        SHOULD_EXPIRE_AT=$(($STARTED_AT_TIMESTAMP + $EXPIRE_LABEL_VALUE))
        
        if (( $CURRENT_TIMESTAMP > $SHOULD_EXPIRE_AT )); then
                echo "Container $container will be removed now"
                docker rm -f $container
        else
                SECONDS_UNTIL_EXPIRE=$(($SHOULD_EXPIRE_AT - $CURRENT_TIMESTAMP))
                echo "Container $container lasts still $SECONDS_UNTIL_EXPIRE seconds before deletion"
        fi
done
