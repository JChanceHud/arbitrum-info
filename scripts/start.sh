#!/bin/sh

set -e

touch .env
source .env

ORIG_DIR=$(pwd)

if [ -z $RINKEBY_URL ]
then
  read -p "Enter a rinkeby node url: " RINKEBY_URL
  echo "RINKEBY_URL=$RINKEBY_URL" >> "$ORIG_DIR/.env"
fi

if [ -z $CONTRACT_ADDR ]
then
  read -p "Enter the rollup contract address: " CONTRACT_ADDR
  set +e
  echo "$CONTRACT_ADDR" | grep -E "^(0x)?[a-fA-F0-9]{40}\$"
  if [ $? -eq 1 ]
  then
    echo "Invalid address supplied!"
    exit 1
  fi
  set -e
  echo "CONTRACT_ADDR=$CONTRACT_ADDR" >> "$ORIG_DIR/.env"
fi

if [ -z $WORK_DIR -o ! -d $WORK_DIR ]
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

cd "$WORK_DIR/arbitrum"

if [ -d "$ORIG_DIR/rollups" -a ! -d "$WORK_DIR/arbitrum/rollups" ]
then
  cp -r "$ORIG_DIR/rollups" "$WORK_DIR/arbitrum/rollups"
fi

if [ ! -d "$WORK_DIR/arbitrum/rollups" ]
then
  yarn prod:initialize $CONTRACT_ADDR $RINKEBY_URL
fi

interrupt() {
  mv "$ORIG_DIR/rollups" "$ORIG_DIR/rollups_bak" || true
  cp -r "$WORK_DIR/arbitrum/rollups" "$ORIG_DIR/rollups"
  rm -rf "$ORIG_DIR/rollups_bak" || true
  exit
}

trap interrupt SIGINT
trap interrupt SIGTSTP

yarn deploy:validators $CONTRACT_ADDR --password=password
