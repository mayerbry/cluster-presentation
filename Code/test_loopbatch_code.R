args<-(commandArgs(TRUE));
if(length(args)==0){
  print("No arguments supplied.")
  
}else{
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  }
  print(args)
}

library(doParallel)
library(plyr)
source("model_functions.R")

registerDoParallel(6)
getDoParWorkers()

total_simulations = 10000

#for the batch we are going to try different infectivities
infectivity_list = c(1.1, 1.5)

#use the inputted values from the bash loop to reduce out subset (change output name)
if(inf_set == 1) infectivity_list = infectivity_list[1]
if(inf_set == 2) infectivity_list = infectivity_list[2]
out_file_name = paste("batch_results/batch_results_loop", inf_set, ".csv", sep = "") #output name varies by input save in folder

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


write.csv(results, out_file_name, row.names = F)

print(Sys.time() - start_time)

