#!/bin/bash
rm -rf ityfuzz-tmp/task-$TASK
mkdir -p ityfuzz-tmp/task-$TASK
cd ityfuzz-tmp/task-$TASK
rm -rf corpus
mkdir corpus
mkdir test
mkdir build
cp /daedaluzz/generated-mazes/maze-$MAZE_NUMBER.sol test/maze-$MAZE_NUMBER.sol
solc test/maze-$MAZE_NUMBER.sol --abi --bin --overwrite -o build/ --optimize --optimize-runs 99999
timeout $TIME_LIMIT ityfuzz evm -t "build/*"
