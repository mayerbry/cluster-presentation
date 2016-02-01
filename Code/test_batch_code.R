library(doParallel)
library(plyr)
source("model_functions.R")

registerDoParallel(6)
getDoParWorkers()

total_simulations = 10000

#for the batch we are going to try different infectivities
infectivity_list = c(1.1, 1.5)

start_time = Sys.time()
results = plyr::ldply(infectivity_list, function(infectivity_in){
  plyr::ldply(1:total_simulations, function(run){ #ldply is like a loop
    simulation = stochastic_model_latent(max_time = 100, initI = 10, infectivity = 1.1, parms,
                                      seed_set = 5)
    last_V = tail(simulation$V, 1)
    data.frame( #just want to know if virus = 0 in the simulation
      run = run,
      infectivity = infectivity_in,
      infection_extinction = (last_V == 0)
    )
  }, .parallel = T) #Just set this .parallel = T after you close the function
}) #<- if you added a .parallel = T here you would need to request 36 cores

write.csv(results, "batch_results.csv", row.names = F)

print(Sys.time() - start_time)

