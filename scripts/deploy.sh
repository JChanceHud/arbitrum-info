#!/bin/sh

set -e

touch .env
source .env

ORIG_DIR=$(pwd)

if [ -z $WORK_DIR ]
then
  WORK_DIR=$(mktemp -d)
  cd $WORK_DIR
  git clone --depth 1 --branch v0.7.3 https://github.com/OffchainLabs/arbitrum.git
  cd arbitrum
  which yarn
  yarn
  # Remove the old WORK_DIR entry
  cat "$ORIG_DIR/.env" | grep -v WORK_DIR > "$ORIG_DIR/.env" || true
  # Put the new one in
  echo "WORK_DIR=$WORK_DIR" >> "$ORIG_DIR/.env"
fi

cd "$WORK_DIR/arbitrum/packages/arb-bridge-eth"

read -p "Enter a rinkeby node url: " RINKEBY_URL
read -p "Enter a rinkeby wallet private key: " RINKEBY_KEY

echo "RINKEBY_URL=$RINKEBY_URL" >> .env
# They expect the MNEMONIC to be a private key 🙄
echo "RINKEBY_MNEMONIC=$RINKEBY_KEY" >> .env

yarn migrate:rinkeby

cd $ORIG_DIR

# Store this for use later
echo "RINKEBY_URL=$RINKEBY_URL" >> .env
echo "RINKEBY_KEY=$RINKEBY_KEY" >> .env
