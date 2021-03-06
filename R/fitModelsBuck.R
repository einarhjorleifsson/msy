#' stock recruitment function
#'
#'
#' @param data data.frame containing stock recruitment data
#' @param runid A character vector
#' @param nsamp Number of samples
#' @param models A character vector
#' @param ... Additional arguements
#' @return log recruitment according to model
#' @author Colin Millar \email{colin.millar@@ices.dk}
#' @export
fitModelsBuck <- function(data, runid, nsamp = 5000, models = c("ricker","segreg","bevholt"), ...)
{

#--------------------------------------------------------
# Fit models
#--------------------------------------------------------

  nllik <- function(param, ...) -1 * llik(param, ...)
  ndat <- nrow(data)
  fit <- lapply(1:nsamp, function(i)
    {
      sdat <- data[sample(1:ndat, replace = TRUE),]

      fits <- lapply(models, function(mod) stats::nlminb(initial(mod, sdat), nllik, data = sdat, model = mod, logpar = TRUE))

      best <- which.min(sapply(fits, "[[", "objective"))

      with(fits[[best]], c(a = exp(par[1]), b = exp(par[2]), cv = exp(par[3]), model = best))
    })

  fit <- as.data.frame(do.call(rbind, fit))
  fit $ model <- models[fit $ model]

#--------------------------------------------------------
# get posterior distribution of estimated recruitment
#--------------------------------------------------------
  pred <- t(sapply(seq(nsamp), function(j) exp(match.fun(fit $ model[j]) (fit[j,], sort(data $ ssb))) ))


#--------------------------------------------------------
# get best fit for each model
#--------------------------------------------------------
  fits <-
    do.call(rbind,
      lapply(models,
           function(mod)
               with(stats::nlminb(initial(mod, data), nllik, data = data, model = mod, logpar = TRUE),
                 data.frame(a = exp(par[1]), b = exp(par[2]), cv = exp(par[3]), model = mod))))


  list(fit = fit, pred = pred, fits = fits, data = data, stknam = runid)
}
