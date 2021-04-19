#!/bin/bash

VERSION=v1
DIST_DIR=dist
DIST_NAME=bitcoin-docker
DIST_ROOT=${DIST_DIR}/${DIST_NAME}

# Format dist file name like: "${DIST_NAME}-${version}-${YYYY-MM-DD}.zip"
DATE=`date "+%Y-%m-%d"`
DIST_FILENAME="${DIST_NAME}-${VERSION}-${DATE}.zip"

# script to create distribution for release
mkdir -v -p ${DIST_ROOT}

# package specific files into the dist
cp -v docker-compose.yml ${DIST_ROOT}
#cp -v docker-compose.override.dist.yml ${DIST_ROOT}/docker-compose.override.yml
cp -v Dockerfile ${DIST_ROOT}
cp -v docker-run.sh ${DIST_ROOT}
cp -v docker-save.sh ${DIST_ROOT}
cp -v README.md ${DIST_ROOT}
# scripts dir partial
mkdir -v ${DIST_ROOT}/scripts
cp -v scripts/start.sh ${DIST_ROOT}/scripts/
cp -v scripts/test-users-setup.sh ${DIST_ROOT}/scripts/

# recursive copy specific directories into the dist dir 
cp -v -R config ${DIST_ROOT}

pushd ${DIST_DIR}
zip -r ${DIST_FILENAME} ${DIST_NAME}
popd
