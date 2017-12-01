#!/usr/bin/env bash

rm -rf build
testrpc --gasPrice=1 --port=8550 --accounts=10 > /dev/null 2>&1 &
truffle test --network=test
kill -9 `ps -ef | grep 'port=8550' | grep testrpc | awk '{print \$2}'`

