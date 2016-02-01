#remember this has to be in the cluster-example folder to access the relative path "batch_results/"
library(plyr)

output_file_names = list.files("batch_results/")

output = ldply(output_file_names, function(file_name){
  read.csv(paste("batch_results/", file_name, sep = ""), stringsAsFactors = F)
})

write.csv(output, "combined_batchloop_output.csv", row.names = F)
