#!/bin/bash

# container timezone TZ env var overrides any system setting in the image.
CONTAINER_TZ="America/New_York"

HOST_PORT=3390
CONTAINER_PORT=3389

printf "Starting ...
mapping container xrdp port: ${HOST_PORT}
to host port: ${HOST_PORT}
setting container timezone: ${CONTAINER_TZ}\n\n"
docker-compose up -d
printf "\n"
printf "Displaying running containers (using 'docker-compose ps'):\n\n"
docker ps -l
printf "\n"
printf "To stop the container: docker-compose down\n\n"
