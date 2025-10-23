#!/bin/bash

echo "Task: $TASK"
echo "Time Limit: $TIME_LIMIT"
echo "Maze: $MAZE_NUMBER"
echo "Seed: $SEED"

forge init --no-git foundry-project
cd foundry-project
cp /daedaluzz/generated-mazes/maze-$MAZE_NUMBER.foundry.sol test/maze-$MAZE_NUMBER.t.sol
cp foundry.toml foundry.original.toml
forge build

# Default settings:
# - fuzz.runs: 256
# - fuzz.max_test_rejects: 65536
# - invariant.runs: 256
# - invariant.depth: 15
RUNS=500  # We also tried several other values, but did not observe a significant change in performance
MAX_TEST_REJECTS=1073741823
DEPTH=100  # We also tried 15 and 30, but observed lower performance.
INIT_SEED=$SEED
RANDOM=$INIT_SEED
START_TIME=$(date +%s)
TIME_LIMIT=$TIME_LIMIT
END_TIME=$((START_TIME + TIME_LIMIT))
while true; do
    NOW_TIME=$(date +%s)
    if [ $END_TIME -lt $NOW_TIME ]; then
        break
    fi
    SEED=$RANDOM
    HEX_SEED=$(printf "0x%x" $SEED)
    cp foundry.original.toml foundry.toml
    printf "\n[fuzz]\nruns = %s\nmax_test_rejects = %s\nseed = '%s'\ndictionary_weight = 40\ninclude_storage = true\ninclude_push_bytes = true\n\n[invariant]\nruns = %s\ndepth = %s\nfail_on_revert = false\ncall_override = false\ndictionary_weight = 80\ninclude_storage = true\ninclude_push_bytes = true\n" $RUNS $MAX_TEST_REJECTS $HEX_SEED $RUNS $DEPTH  >> foundry.toml
    forge test --match-path test/maze-$MAZE_NUMBER.t.sol --fuzz-seed $HEX_SEED
done

ls -la cache/invariant/failures/TestMaze/
violations=($(find "cache/invariant/failures/TestMaze/" -maxdepth 1 -name 'invariant_*' -printf '%f\n' | sort))
echo "{\"program\": \"maze-$MAZE_NUMBER\", \"tool\": \"foundry\", \"violations\": \"${#violations[@]}\", \"random-seed\": \"$SEED\", \"duration\": \"$TIME_LIMIT\"}" > /daedaluzz/generated-mazes/results/foundry-results.json
