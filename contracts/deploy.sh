#!/bin/bash

## export .env variables to ENVIRONMENT
export $(xargs <.env)

if [ "$#" -ne 5 ]; then
    echo "---- 5 constructor args required, Provided $#. ---- Omitting Eco.sol ......."
else
    echo "deploying the ego contract ..."
    ## deploy the ego contract
    forge create --rpc-url $EVMOS_RPC_URL --private-key $ETH_PRIVATE_KEY src/Ego.sol:Ego --constructor-args $1 $2 $3 $4 $5
fi

echo "deploying the oracle contract ..."
## deploy test oracle
forge create --rpc-url $EVMOS_RPC_URL --private-key $ETH_PRIVATE_KEY src/lib/utils/DiaOracle.sol:TestOracle
