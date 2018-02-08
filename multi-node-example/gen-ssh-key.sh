#!/bin/bash
set -eu -o pipefail

if [ -e ./tmp ]; then echo "$dirname exists. Skipped."; exit 0; fi

mkdir -p ./tmp/ssh-key

set +e
yes | ssh-keygen -N "" -f ./tmp/ssh-key/id_rsa
set -e
cp ./tmp/ssh-key/id_rsa.pub ./tmp/ssh-key/authorized_keys
chmod 700 ./tmp/ssh-key
chmod 600 ./tmp/ssh-key/*
