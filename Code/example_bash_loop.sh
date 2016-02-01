#!/bin/bash

for x in {1,2}; do
sbatch --cpus-per-task=6 --time=0-1 --wrap="R --no-save --no-restore '--args inf_set=$x' < test_loopbatch_code.R"
done