run_model <- function(jags_parameters, config, model_file, log_file = NULL) {
    write_log(sprintf("Running model with file: %s", model_file), log_file = log_file)
    #init function for chains
    in_init <- function(M_fit=jags_parameters$M_fit) {
        list(a = rep(0, M_fit))
    }

    raw_model_output <- R2jags::jags(
                               data = jags_parameters,
                               inits = in_init,
                               parameters.to.save = as.vector(config$JAGS_DATA$save_parameters),
                               model.file = model_file,
                               n.chains = config$JAGS_DATA$chains,
                               n.iter = config$JAGS_DATA$iterations,
                               n.burnin = config$JAGS_DATA$burn_in,
                               n.thin = config$JAGS_DATA$thin,
                               DIC = FALSE)
    model_output_size <- format(object.size(raw_model_output), units = "Mb")
    write_log(paste("model finished with size:", model_output_size), log_file = log_file)
    return(raw_model_output)
}