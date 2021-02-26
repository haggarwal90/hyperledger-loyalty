#!/bin/bash

export FABRIC_CFG_PATH=$(pwd)/artifacts/channel/config/
export PATH=${PWD}/bin:$PATH

export ORDERER_CA=$(pwd)/artifacts/channel/crypto-config/ordererOrganizations/loyaltybenefits.com/orderers/orderer.loyaltybenefits.com/msp/tlscacerts/tlsca.loyaltybenefits.com-cert.pem
export CORE_PEER_TLS_ENABLED=true
export CHANNEL_NAME=mychannel

export PEER0_COFFEECAFE_CA=$(pwd)/artifacts/channel/crypto-config/peerOrganizations/coffeecafe.loyaltybenefits.com/peers/peer0.coffeecafe.loyaltybenefits.com/tls/ca.crt
export PEER0_BOOKSTORE_CA=$(pwd)/artifacts/channel/crypto-config/peerOrganizations/bookstore.loyaltybenefits.com/peers/peer0.bookstore.loyaltybenefits.com/tls/ca.crt
export PEER0_RETAILSTORE_CA=$(pwd)/artifacts/channel/crypto-config/peerOrganizations/retailstore.loyaltybenefits.com/peers/peer0.retailstore.loyaltybenefits.com/tls/ca.crt


setGlobalsForPeer0Bookstore() {
  export CORE_PEER_LOCALMSPID=BookstoreMSP
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BOOKSTORE_CA
  export CORE_PEER_MSPCONFIGPATH=$(pwd)/artifacts/channel/crypto-config/peerOrganizations/bookstore.loyaltybenefits.com/users/Admin@bookstore.loyaltybenefits.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Retailstore() {
  export CORE_PEER_LOCALMSPID=RetailstoreMSP
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RETAILSTORE_CA
  export CORE_PEER_MSPCONFIGPATH=$(pwd)/artifacts/channel/crypto-config/peerOrganizations/retailstore.loyaltybenefits.com/users/Admin@retailstore.loyaltybenefits.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
}

setGlobalsForPeer0Coffeecafe() {
  export CORE_PEER_LOCALMSPID=CoffeecafeMSP
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COFFEECAFE_CA
  export CORE_PEER_MSPCONFIGPATH=$(pwd)/artifacts/channel/crypto-config/peerOrganizations/coffeecafe.loyaltybenefits.com/users/Admin@coffeecafe.loyaltybenefits.com/msp
  export CORE_PEER_ADDRESS=localhost:10051
}

createChannel() {
  echo "creating channel.."
  setGlobalsForPeer0Bookstore
  peer channel create -o localhost:7050 -c $CHANNEL_NAME \
      --ordererTLSHostnameOverride orderer.loyaltybenefits.com \
      -f $(pwd)/artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

joinChannelBookstore() {
  echo "bookstore joining channel.."
  setGlobalsForPeer0Bookstore
  peer channel join -b ./channel-artifacts/mychannel.block
}

joinChannelRetailstore() {
  echo "retailstore joining channel.."
  setGlobalsForPeer0Retailstore
  peer channel join -b ./channel-artifacts/mychannel.block
}

joinChannelCoffeecafe() {
  echo "coffeecafe joining channel.."
  setGlobalsForPeer0Coffeecafe
  peer channel join -b ./channel-artifacts/mychannel.block
}

createChannel
joinChannelBookstore
joinChannelRetailstore
joinChannelCoffeecafe

