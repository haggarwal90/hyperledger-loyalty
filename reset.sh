#!/bin/bash

export CURRENT_DIR=$(pwd)
export FABRIC_CFG_PATH=$CURRENT_DIR/artifacts/channel/config
export PATH=${PWD}/bin:$PATH

echo FABRIC_CFG_PATH=$FABRIC_CFG_PATH
echo PATH=$PATH

stop() {
  echo Stop Containers

  cd $CURRENT_DIR/docker/

  docker-compose down

  echo Containers stopped, remove files..

  cd $CURRENT_DIR

  rm $CURRENT_DIR/artifacts/channel/genesis.block

  rm $CURRENT_DIR/artifacts/channel/mychannel.tx

  rm -rf $CURRENT_DIR/channel-artifacts/*

  echo artifacts files removed

  rm -rf ${CURRENT_DIR}/artifacts/channel/crypto-config/

  echo Crytpo material removed
}

start() {
  echo Create Crypto material

  cd ${CURRENT_DIR}/artifacts/channel

  sh create-crypto-material.sh

  echo Create artifacts

  cd $CURRENT_DIR/artifacts/channel

  sh create-artifacts.sh

  echo artifacts created, start docker

  cd $CURRENT_DIR/docker/

  docker-compose up -d --remove-orphans

  echo container started
}

# stop
start
