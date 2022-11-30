#!/bin/bash

export $(xargs <.env)

deploy_local() {
    if [ "$1" = "local" ]; then
        echo "########## ---- deploying on localhost ... ---- ##########"
        pkill anvil
        echo "starting anvil ..."
        anvil &
        sleep 15
        forge script script/Deployment.s.sol:DeploymentScript --fork-url http://localhost:8545 --broadcast
    else
        echo "Input Error: unknown argument at position 1; $1 != local"
    fi
}

deploy_local_fork() {
    if [ "$1" = "local" ] && [ "$2" = "--fork" ]; then
        echo "########## ---- deploying on testnet fork ... ---- ##########"
        pkill anvil
        echo "starting anvil ..."
        anvil --fork-url $EVMOS_RPC_URL &
        sleep 15
        forge script script/Deployment.s.sol:DeploymentScript --fork-url $EVMOS_RPC_URL --broadcast
    else
        echo "Input Error: unknown argument passed: usage sh ./rundeployScript.sh [local] [--fork]"
        echo "check that $1 == local and $2 == --fork"
    fi
}

if [ "$#" -eq 1 ]; then
    deploy_local $1
elif [ "$#" -eq 2 ]; then
    deploy_local_fork "$1" "$2"
elif [ -n "$1" ]; then
    echo "invalid number of arguments passed"
    echo "usage: sh ./rundeployScript.sh [local] [--fork]"
    echo "example: sh ./rundeployScript.sh local --fork"
else
    echo "########## ---- deploying on live testnet ... ---- ##########"
    forge script script/Deployment.s.sol:DeploymentScript --rpc-url $EVMOS_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
fi
