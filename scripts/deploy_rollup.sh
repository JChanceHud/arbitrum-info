#!/bin/sh

set -e

WORK_DIR=$(mktemp -d)

cd $WORK_DIR
git clone https://github.com/JChanceHud/arbitrum-deployment-website.git
cd arbitrum-deployment-website
yarn
yarn start
