library(doParallel)
library(plyr)
source("model_functions.R")

registerDoParallel(6)
getDoParWorkers()

total_simulations = 10000

start_time = Sys.time()
example_simulations =  foreach(run = 1:total_simulations, .combine=rbind) %dopar% {
  results = stochastic_model_latent(max_time = 100, initI = 10, infectivity = 1.1, parms,
                                    seed_set = 5)
  results$run = run #keep track of the run
  results
}
print("Running 10000 foreach simulations")
print(Sys.time() - start_time)

rm(example_simulations)

start_time = Sys.time()
example_simulations = plyr::ldply(1:total_simulations, function(run){ #ldply is like a loop
  results = stochastic_model_latent(max_time = 100, initI = 10, infectivity = 1.1, parms,
                                    seed_set = 5)
  results$run = run #keep track of the run
  results
}, .parallel = T) #Just set this .parallel = T after you close the function

print("Running 10000 plyr simulations")
print(Sys.time() - start_time)

