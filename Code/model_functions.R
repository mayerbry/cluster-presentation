parms = data.frame(
  beta = NA, #viral infectivity (cells infected per virus per day)
  c = 2, #Free virus death rate, per day
  initS = 1e7 * 40,  #Total susceptible cells
  mu = 1/4.5, #Death rate of susceptible cells per day
  lambda = 4e8 / 4.5, #new susceptible cells per day, lambda = mu * initS
  delta = 0.77, #infected cell death/day 
  alpha = 1, #days before infected cell has replicating virus (latency)
  p = 1600 #virus/cell/day 
)

stochastic_model_latent = function(max_time, initI = 1, infectivity = 1.05, parms, 
                                   tao = 0.1, seed_set = NULL){
  if(!is.null(seed_set)) set.seed(seed_set) #reproduce results
  parms$beta = infectivity/with(parms, p * initS/ (c * delta *(1+mu/alpha)))
  
  
  time_vec = seq(0, max_time, tao)
  out_index = length(time_vec)
  
  I0_vec =rep(0, out_index)
  I_vec = rep(0, out_index)
  V_vec = rep(0, out_index)
  
  #initial
  S = parms$initS
  V = 0
  I0 = 0
  I = initI
  
  I_vec[1] = initI

  for(i in 2:out_index){
    
    events = tao * with(as.list(parms),
                        c(
                          beta * S * V, 
                          alpha * I0,
                          mu * I0,
                          delta * I, 
                          p * I, 
                          c * V
                        )
    )
    
    if(length(which(events < 0)) > 0) events[which(events < 0)] = 0 #no negative events
    
    infected = rpois(1, events[1])
    latent_out = rpois(1, events[2])
    latent_death = rpois(1, events[3])
    infected_death = rpois(1, events[4])
    newV = rpois(1, events[5])
    deathV = rpois(1, events[6]) #death and immune clr    
    
    #if(i > 100) browser()
    
    I0 = max(0, I0 + infected - latent_out - latent_death)
    I = max(0, I + latent_out - infected_death)
    V = max(0, V + newV - deathV)
    
    #these are updated (or not updated) in the conditionals
    I0_vec[i] = I0
    I_vec[i] = I
    V_vec[i] = V
    
    if(is.na(V)) browser()
    
    if((I == 0 & V == 0 & I0 == 0) | V > 1e9){
      out_index = i
      break
    }
  }

  out = data.frame(
    time = time_vec[1:out_index],
    I0 = I0_vec[1:out_index],
    I = I_vec[1:out_index],
    V = V_vec[1:out_index]
    )
  out$viral_load = with(out, ifelse(V > 1, log10(V), 0))
  out
}

ODEmodel_latent = function(t, x, parms){ #these inputs are convention for ODE models in R: 
  #t = time, x = vector of population sizes at current time, parms = parameters
  with(as.list(c(parms, x)), {
    dS <- lambda - mu * S - beta * S * V
    dI0 <- beta * S * V - mu * I0 - alpha * I0
    dI <- alpha * I0 -  delta * I
    dV <- p * I - c * V 
    
    res <- c(dS, dI0, dI, dV)
    list(res)
  })
}

