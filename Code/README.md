# Code for presentation and examples
## model_functions.R needs to be accessible for all examples (remote and local cluster_presentation.Rpres).

## Remote server code

For all R server scripts to work, must be in the same directory as model_functions.R

### test_server_code.R
Can be called with R CMD BATCH in the terminal or by using "source" in an R session. Nothing is saved.

### test_batch_code.R
This can be called both by R CMD BATCH and using an sbatch call in the terminal. Saves an aggregated results file.

### Looping batch code
To run this code, there must be an additional subdirectory created called 'batch_results'. `mkdir batch_results` in the command line.

#### test_loopbatch_code.R
This R script is setup to be called by example_bash_loop.sh where it is given an external input. Saves an aggregated results file similar to test_batch_code.R in batch_results/.

#### example_bash_loop.sh
This bash script file runs a loop that sends multiple jobs to the server and a varying parameter settings to test_loopbatch_code.R

#### combine_batch_output.R
This script combines the output created by example_bash_loop.R
