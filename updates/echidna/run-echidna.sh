#!/bin/bash

echo "Task: $TASK"
echo "Time Limit: $TIME_LIMIT"
echo "Maze: $MAZE_NUMBER"
echo "Seed: $SEED"

solc-select install 0.8.19
solc-select use 0.8.19
rm -rf echidna-tmp/task-$TASK
mkdir echidna-tmp/task-$TASK
cd echidna-tmp/task-$TASK
rm -rf echidna-corpus
mkdir echidna-corpus

# Default settings:
# - testLimit: 50000
# - shrinkLimit: 5000
# - codeSize: 0x6000
TEST_LIMIT=1073741823
SHRINK_LIMIT=5000  # We also tried 0, but did not observe a noticeable change in performance.
CODE_SIZE='0xc00000'
printf 'testMode: "exploration"\ntestLimit: %s\nstopOnFail: false\ntimeout: %s\nseqLen: 100\nshrinkLimit: %s\ncoverage: true\nformat: text\ncodeSize: %s\nseed: %d\ncorpusDir: echidna-corpus\n' $TEST_LIMIT $TIME_LIMIT $SHRINK_LIMIT $CODE_SIZE $SEED > echidna-config.yaml
echidna-test --config echidna-config.yaml --contract Maze /daedaluzz/generated-mazes/maze-$MAZE_NUMBER.sol
grep "[*roe]\s*|\s*emit AssertionFailed" echidna-corpus/covered.*.txt
violations=$(grep "[*roe]\s*|\s*emit AssertionFailed" echidna-corpus/covered.*.txt | wc -l)
echo "{\"program\": \"maze-$MAZE_NUMBER\", \"tool\": \"echidna\", \"violations\": \"$violations\", \"random-seed\": \"$SEED\", \"duration\": \"$TIME_LIMIT\"}" > /daedaluzz/generated-mazes/results/echidna-results.json
