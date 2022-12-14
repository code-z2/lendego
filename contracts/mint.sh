#!/bin/bash

## export .env variables to ENVIRONMENT
export $(xargs <.env)

echo "########## ---- minting!!! please be patient ---- ##########"

## deploy a token contract
mint_stable() {
    cast send --private-key $PRIVATE_KEY --rpc-url $EVMOS_RPC_URL $1 "mint(address,uint256)" $2 1000000000000
}

mint_liquid() {
    cast send --private-key $PRIVATE_KEY --rpc-url $EVMOS_RPC_URL $1 "mint(address,uint256)" $2 1000000000000000000000
}

stables='0x72c91eD03b71694Cd5C08c01eFc504311D60d76d 0x3369B66Cc041132f596317830ae36B91FAAC9e53 0xCD65d9e43151CFdf2173F45a4B10A1F0ecD901D2 0x9c18C4b97452828Ad4040EBaEca1aF32B099F863'
liquids='0x8D3F60D7689A23570ebB08C1552dcbF5Cb949e8d 0x759C1d32865617E0dF2044888C9c8e07Bd6d5EbD 0x67f54b40FaCcA8FB38B68b28578a7AC0D9Ffb0f3'

for token in $stables; do
    mint_stable "$token" "$1"
done

for token in $liquids; do
    mint_liquid "$token" "$1"
done

echo "########## ---- done!!! ---- ##########"
