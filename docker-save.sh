#!/bin/bash

IMAGE=msats-bitcoin

SAVE_OUTPUT_FILE="${IMAGE}_`date "+%Y-%m-%d"`.tar.gz"

echo "Saving image ${IMAGE} as ${SAVE_OUTPUT_FILE} ..."
docker save ${IMAGE} | gzip > ${SAVE_OUTPUT_FILE}
