#!/bin/bash

cryptogen generate --config=${CURRENT_DIR}/artifacts/channel/cryptogen/crypto-config-orderer.yaml --output=${CURRENT_DIR}/artifacts/channel/crypto-config/

cryptogen generate --config=${CURRENT_DIR}/artifacts/channel/cryptogen/crypto-config-bookstore.yaml --output=${CURRENT_DIR}/artifacts/channel/crypto-config/

cryptogen generate --config=${CURRENT_DIR}/artifacts/channel/cryptogen/crypto-config-coffeecafe.yaml --output=${CURRENT_DIR}/artifacts/channel/crypto-config/

cryptogen generate --config=${CURRENT_DIR}/artifacts/channel/cryptogen/crypto-config-retailstore.yaml --output=${CURRENT_DIR}/artifacts/channel/crypto-config/