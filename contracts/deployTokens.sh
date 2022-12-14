#!/bin/bash

## export .env variables to ENVIRONMENT
export $(xargs <.env)

## deploy a token contract
deploy_token() {
    echo "########## deploying the $1 token contract ##########"
    forge create --rpc-url $EVMOS_RPC_URL --private-key $PRIVATE_KEY src/tokens/ERC20/DevERC20.sol:$1
    echo "########## ---- successfully deployed $1 ---- ##########"/n
}

contracts='Atom WrappedEvmos WrappedETH Dia USDC USDT Dai BUSD FraxShare'

for token in $contracts; do
    deploy_token $token
done
