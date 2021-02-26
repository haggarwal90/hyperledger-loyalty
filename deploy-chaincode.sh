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



CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./chaincode/customer-loyalty"
CC_NAME="loyalty"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Bookstore
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.bookstore ===================== "
}

installChaincode() {
    setGlobalsForPeer0Bookstore
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.bookstore ===================== "

    setGlobalsForPeer0Retailstore
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer.retailstore ===================== "

    setGlobalsForPeer0Coffeecafe
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.coffecafe ===================== "
}

queryInstalled() {
    setGlobalsForPeer0Bookstore
    # setGlobalsForPeer0Proccessor => Package Id is same for all the peers
    peer lifecycle chaincode queryinstalled > log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.bookstore on channel ===================== "
}

approveForBookstore() {
    setGlobalsForPeer0Bookstore
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.loyaltybenefits.com --tls ${CORE_PEER_TLS_ENABLED}\
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

approveForRetailstore() {
    setGlobalsForPeer0Retailstore
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.loyaltybenefits.com --tls ${CORE_PEER_TLS_ENABLED}\
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

approveForCoffeecafe() {
    setGlobalsForPeer0Coffeecafe
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.loyaltybenefits.com --tls ${CORE_PEER_TLS_ENABLED}\
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

checkCommitReadyness() {
    setGlobalsForPeer0Bookstore
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Bookstore ===================== "
}

commitChaincodeDefination() {
    setGlobalsForPeer0Bookstore
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.loyaltybenefits.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      --channelID $CHANNEL_NAME --name ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BOOKSTORE_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_RETAILSTORE_CA \
      --peerAddresses localhost:10051 --tlsRootCertFiles $PEER0_COFFEECAFE_CA \
      --version ${VERSION} --sequence ${VERSION} --init-required

}


queryCommitted() {
    setGlobalsForPeer0Bookstore
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer0Bookstore
    peer chaincode invoke -o localhost:7050 \
      --ordererTLSHostnameOverride orderer.loyaltybenefits.com \
      --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
      -C $CHANNEL_NAME -n ${CC_NAME} \
      --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BOOKSTORE_CA \
      --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_RETAILSTORE_CA \
      --peerAddresses localhost:10051 --tlsRootCertFiles $PEER0_COFFEECAFE_CA \
      --isInit -c '{"Args":[]}'
}

chaincodeInvoke() {
    setGlobalsForPeer0Bookstore
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.loyaltybenefits.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BOOKSTORE_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_RETAILSTORE_CA \
        --peerAddresses localhost:10051 --tlsRootCertFiles $PEER0_COFFEECAFE_CA \
        -c '{"function":"CreateMember","Args":["{\"accountNumber\":\"acc_1\",\"name\":\"Himanshu Agagrwal\"}"]}'
}

chaincodeQuery() {
    setGlobalsForPeer0Bookstore

    # Query all cars
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'

    # Query Car by Id
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["CAR0"]}'
}

upgradechaincode() {
    peer chaincode upgrade -o localhost:7050 \
        -C $CHANNEL_NAME -n ${CC_NAME}
        -v 1.2 -c '{"Args":["init","a","100","b","200","c","300"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"
}


# packageChaincode
# installChaincode
# queryInstalled
# approveForBookstore
# approveForRetailstore
# approveForCoffeecafe
# checkCommitReadyness
# commitChaincodeDefination
# queryCommitted
# chaincodeInvokeInit
chaincodeInvoke
# chaincodeQuery

