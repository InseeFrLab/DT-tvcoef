library(tvCoef)
all_y <- lapply(
  readRDS("results/all_models.RDS"),
  function(sect){
    lapply(sect, function(mod) get_data(mod)[,1])
  })
# Pour prendre en compte les ruptures
first_date <- 2013
oos <- list(
  lm = lapply(
    readRDS("results/lm_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "residuals")
    }),
  reg_morc = lapply(
    readRDS("results/reg_morc_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "residuals")
    }),
  reg_loc = lapply(
    readRDS("results/reg_loc_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "residuals")
    }),
  reg_loc_fixed_bw = lapply(
    readRDS("results/reg_loc_fixed_bw_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "residuals")
    }),
  reg_morc_loc = lapply(
    readRDS("results/reg_morc_loc_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "residuals")
    }),
  reg_morc_loc_fixed_bw = lapply(
    readRDS("results/reg_morc_loc_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "residuals")
    }),
  ssm = lapply(
    readRDS("results/ssm_oos.RDS"),
    function(sect){
      lapply(sect, `[[`, "oos_noise")
    })
)

# On ajoute le format ts pour les regression locales
oos[grep("_loc", names(oos))] <- lapply(oos[grep("_loc", names(oos))], function(meth){
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
(lapply(oos, function(x)
       lapply(x, function(y) lapply(y, start))))
oos_stats <- do.call(rbind, lapply(seq_along(oos), function(i_meth) {
  do.call(rbind, lapply(seq_along(oos[[i_meth]]), function(i_sect){
    do.call(rbind, lapply(seq_along(oos[[i_meth]][[i_sect]]), function(i_mod){
      stats <- accuracy_mod(oos[[i_meth]][[i_sect]][[i_mod]],
                            all_y[[i_sect]][[i_mod]],
                            start = first_date)
      res <- data.frame(names(all_y)[[i_sect]],
                        i_mod, 
                        names(oos)[i_meth],
                        matrix(stats, nrow = 1))
      colnames(res) <- c("Sector", "Model", "Method", names(stats))
      res
    }))
  }))
}))

ruptures <- readRDS("results/ruptures.RDS") 

oos_stats <- merge(oos_stats, ruptures, all.x = TRUE)
saveRDS(oos_stats, "results/oos_stats.RDS")
