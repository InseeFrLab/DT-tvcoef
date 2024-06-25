library(tvCoef)
all_y <- lapply(
  readRDS("results/all_models.RDS"),
  function(sect){
    lapply(sect, function(mod) get_data(mod)[,1])
  })
# Pour prendre en compte les lags
first_date <- 2000
is <- list(
  lm = lapply(
    readRDS("results/all_models.RDS"),
    function(sect){
      lapply(sect, residuals)
    }),
  reg_morc = lapply(
    readRDS("results/reg_morc.RDS"),
    function(sect){
      lapply(sect, residuals)
    }),
  reg_loc = lapply(
    readRDS("results/reg_loc.RDS"),
    function(sect){
      lapply(sect, residuals)
    }),
  reg_morc_loc = lapply(
    readRDS("results/reg_morc_loc.RDS"),
    function(sect){
      lapply(sect, residuals)
    }),
  ssm = lapply(
    readRDS("results/ssm.RDS"),
    function(sect){
      lapply(sect, 
             # smoothed
             function(x) residuals(x)[,1])
    })
)
# On ajoute le format ts pour les regression locales
is[grep("_loc", names(is))] <-lapply(is[grep("_loc", names(is))], function(meth){
  all_res <- lapply(seq_along(meth), function(i_sect){
    lapply(seq_along(meth[[i_sect]]), function(i_mod){
      y <- all_y[[i_sect]][[i_mod]]
      ts(meth[[i_sect]][[i_mod]],
         end = end(y),
         frequency = frequency(y))
    })
  })
  names(all_res) <- names(meth)
  all_res
})
lapply(is$lm,
       function(sec){
         sapply(sec, function(x)time(x)[1])
       })

accuracy_mod <- function(res, y, start = start(res)){
  res <- window(res, start = start, extend = TRUE)
  y <- window(y, start = start, extend = TRUE)
  Q <- mean(abs(diff(y)))
  stat <- c(rmse(res),
            mean(abs(res)),
            mean(abs(res)/Q))
  names(stat) <- c("RMSE", "MAE", "MASE")
  stat
}
is_stats <- do.call(rbind, lapply(seq_along(is), function(i_meth) {
  do.call(rbind, lapply(seq_along(is[[i_meth]]), function(i_sect){
    do.call(rbind, lapply(seq_along(is[[i_meth]][[i_sect]]), function(i_mod){
      stats <- accuracy_mod(is[[i_meth]][[i_sect]][[i_mod]],
                            all_y[[i_sect]][[i_mod]],
                            start = first_date)
      res <- data.frame(names(all_y)[[i_sect]],
                        i_mod, 
                        names(is)[i_meth],
                        matrix(stats, nrow = 1))
      colnames(res) <- c("Sector", "Model", "Method", names(stats))
      res
    }))
  }))
}))
ruptures <- readRDS("results/ruptures.RDS") 

is_stats <- merge(is_stats, ruptures, all.x = TRUE)
saveRDS(is_stats, "results/is_stats.RDS")
