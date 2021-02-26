#!/bin/bash

# configtxgen uses configtx.yaml specified by CFG_PATH

configtxgen -profile SupplyOrdererGenesis -channelID sys-channel  -outputBlock ./genesis.block

configtxgen -profile SupplyChannel -channelID mychannel -outputCreateChannelTx ./mychannel.tx 