#!/bin/bash

echo "start downloading external-lib..."

curl -o external.zip 'http://static.lajoin.com/wallet/def_wallet_for_ios_external.zip'

echo "finish download external-lib."

unzip external.zip

echo "finish"