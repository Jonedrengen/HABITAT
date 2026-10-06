run_model <- function(jags_parameters, config, model_file, log_file = NULL, temp_dir = NULL) {
    #outputs results in a list of objects
    
    write_log(sprintf("Running model with file: %s", model_file), log_file = log_file)
    #init function for chains
    in_init <- function(M_fit=jags_parameters$M_fit) {
        list(a = rnorm(M_fit, 0, 0.5))
    }

    raw_model_output <- R2jags::jags(
                               data               = jags_parameters,
                               inits              = in_init,
                               parameters.to.save = as.vector(config$JAGS_DATA$save_parameters),
                               model.file         = model_file,
                               n.chains           = config$JAGS_DATA$chains,
                               n.iter             = config$JAGS_DATA$iterations,
                               n.burnin           = config$JAGS_DATA$burn_in,
                               n.thin             = config$JAGS_DATA$thin,
                               DIC                = FALSE)
    model_output_size <- format(object.size(raw_model_output), units = "Mb")
    write_log(paste("model finished with size:", model_output_size), log_file = log_file)
    
    model_results <- list(
                            raw_model_output = raw_model_output,
                            bugs_summary_table = raw_model_output$BUGSoutput$summary,
                            pi_samples = raw_model_output$BUGSoutput$sims.list$pi,      # n_iter x M_fit
                            p_samples = raw_model_output$BUGSoutput$sims.list$p,        # n_iter x M_fit x K
                            eta_samples = raw_model_output$BUGSoutput$sims.list$eta,    # n_iter x N
                            mcmc_object = coda::as.mcmc(raw_model_output)
                        )
    if (!is.null(temp_dir)) {
        write_csv(model_results$bugs_summary_table, include_row_names = TRUE, file_path = file.path(temp_dir, "bugs_summary_table.csv"))
    }
    write_log(paste("Model outputs: ", paste(names(model_results), collapse = ", ")), log_file = log_file)
    return(model_results)
}

#by Daniel Park (both)
#chain histories
plot_results <- function(expression = "", mcmc_object) {
    plot(mcmc_object[, grep(expression, coda::varnames(mcmc_object))])
}
#retrieve specific parameter samples from coda object
get_res   <- function(expression = "", mcmc_object) {
    mcmc_object[,grep(expression, varnames(mcmc_object))]
}
