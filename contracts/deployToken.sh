#!/bin/bash

## export .env variables to ENVIRONMENT
export $(xargs <.env)

## deploy a token contract
deploy_token() {
    forge create --rpc-url $EVMOS_RPC_URL --private-key $ETH_PRIVATE_KEY src/tokens/ERC20/DevERC20.sol:$1
}

for arg; do
    echo "deploying the $arg token contract ..."
    deploy_token $arg
done
