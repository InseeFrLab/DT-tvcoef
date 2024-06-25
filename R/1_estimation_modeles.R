library(tvCoef)
library(dynlm)
library(strucchange)

if (!dir.exists("results"))
  dir.create("results")

data <- window(manufacturing,
               start = c(1990, 1),
               end = c(2019, 4))

all_models_formula <-
  list(
    C = list(
      "manuf_prod ~ ind2008Q4 + ind2009Q1  + overhang_ipi0 + diff(insee_tppa_m2, 1)",
      "manuf_prod ~ overhang_ipi1 + insee_bc_m2  + diff(insee_bc_m2, 1)",
      "manuf_prod ~ overhang_ipi1 + bdf_prodpre_m1  + diff(bdf_tuc_m1, 1)",
      "manuf_prod ~ overhang_ipi1 +insee_tppre_m2 + diff(insee_oscd_m2, 1)",
      "manuf_prod ~ overhang_ipi1 +insee_tppa_m1 + diff(bdf_prodpre_m1, 1)"
    ),
    C1 = list(
      "prod_c1 ~ insee_bc_c1_m1 + insee_tppa_c1_m1 + diff(insee_oscd_c1_m1, 1)",
      "prod_c1 ~ overhang_ipi1_c1 + bdf_prodpas_c1_m2",
      "prod_c1 ~ insee_bc_c1_m1 + insee_tppa_c1_m1 + diff(insee_oscd_c1_m1, 1)",
      "prod_c1 ~ overhang_ipi1_c1 + diff(insee_bc_c1_m2, 1)",
      "prod_c1 ~ overhang_ipi1_c1"
    ),
    C3 = list(
      "prod_c3 ~ overhang_ipi1_c3 + bdf_evocar_c3_m2",
      "prod_c3 ~ insee_bc_c3_m1 + insee_tppre_c3_m1 + diff(insee_tppre_c3_m1, 1) +
        ind2009Q1",
      "prod_c3 ~ overhang_ipi1_c3 + insee_tppa_c3_m2 + insee_tppre_c3_m2 +
        bdf_evocar_c3_m2",
      "prod_c3 ~ insee_bc_c3_m1 + insee_tppre_c3_m1 + diff(insee_tppre_c3_m1, 1) +
        ind2009Q1",
      "prod_c3 ~ insee_tppre_c3_m1 + insee_tppa_c3_m1 + diff(insee_bc_c3_m2, 1) +
        ind2009Q1",
      "prod_c3 ~ overhang_ipi1_c3 + insee_bc_c3_m3 + diff(insee_tppre_c3_m3, 1)"
    ),
    C4 = list(
      "prod_c4 ~ diff(insee_bc_c4_m1) + insee_tppre_c4_m1 + stats::lag(insee_oscd_c4_m2, -1) +
        ind2008Q4",
      "prod_c4 ~ overhang_ipi1_c4 + bdf_prodpas_c4_m2 + diff(insee_oscd_c4_m3, 1)",
      "prod_c4 ~ overhang_ipi1_c4 + insee_tppa_c4_m2 + bdf_prodpas_c4_m2 +
        diff(insee_oscd_c4_m2, 1)",
      "prod_c4 ~ diff(insee_bc_c4_m1) + insee_tppre_c4_m1 + stats::lag(insee_oscd_c4_m2, -1) +
        ind2008Q4",
      "prod_c4 ~ overhang_ipi0_c4 + diff(insee_bc_c4_m2, 1) + bdf_prodpas_c4_m1 +
        diff(bdf_tuc_c4_m1, 1)",
      "prod_c4 ~ overhang_ipi1_c4 + diff(insee_bc_c4_m3, 1) + bdf_prodpas_c4_m2 +
        ind2008Q4"
    ),
    C5 = list(
      "prod_c5 ~ insee_bc_c5_m1 + diff(insee_tppre_c5_m1, 1) +
        ind2008Q4 + ind2009Q1",
      "prod_c5 ~ overhang_ipi1_c5 + bdf_prodpas_c5_m2 + stats::lag(insee_oscd_c5_m3, -1) +
        diff(bdf_sitcar_c5_m2, 1)",
      "prod_c5 ~ overhang_ipi1_c5 + bdf_prodpas_c5_m2 +
        diff(bdf_evocar_c5_m2, 1) + diff(insee_tppre_c5_m2, 1)",
      "prod_c5 ~ insee_bc_c5_m1 + diff(insee_tppre_c5_m1, 1) +
        ind2008Q4 + ind2009Q1",
      "prod_c5 ~ stats::lag(prod_c5, -1) + bdf_prodpre_c5_m1 +
      diff(insee_bc_c5_m2, 1) + diff(bdf_tuc_c5_m1, 1) + ind2008Q4 + ind2009Q1",
      "prod_c5 ~ overhang_ipi1_c5 + insee_bc_c5_m3 + insee_oscd_c5_m2 +
      diff(insee_tppre_c5_m3, 1) + diff(bdf_tuc_c5_m2, 1)"
    )
  )

if (!file.exists("results/all_models.RDS")) {
  all_models <- lapply(all_models_formula, function(sect) {
    lapply(sect, function(form) {
      dynlm(as.formula(form), data = data)
    })
  })
  saveRDS(all_models, "results/all_models.RDS")
} else {
  all_models <- readRDS("results/all_models.RDS")
}


all_bp <- lapply(all_models, function(sect) {
  # On restreint à au plus deux ruptures
  lapply(lapply(sect, breakpoints, breaks = 2), breakdates)
})
if (!file.exists("results/ruptures.RDS")) {
  nb_rupture_bp <- lapply(all_bp, function(sect) {
    sapply(sect, function(bp) {
      sum(!is.na(bp))
    })
  })
  
  all_hansen <- lapply(all_models, function(sect) {
    sapply(sect, function(model) {
      test <- hansen_test(model,
                          # On enlève les indicatrices
                          var = grep("ind", names(coef(model)), invert = TRUE))
      test$L_c > hansen_table[length(test$selected_var), "5%"]
    })
  })
  mod_by_sect <- lapply(all_models_formula, length)
  Sector <- unlist(lapply(names(mod_by_sect), function(sect){
    rep(sect, mod_by_sect[[sect]])
  }))
  Model <- unlist(lapply(mod_by_sect, function(nb){
    seq_len(nb)
  }))
  ruptures <- data.frame(
    Sector = Sector,
    Model = Model,                
    `Bai et Perron` = unlist(nb_rupture_bp) > 0,
    Hansen = unlist(all_hansen),
    check.names = FALSE
  )
  rownames(ruptures) <- NULL
  saveRDS(ruptures, "results/ruptures.RDS")
}

########################################################
################ Estimation des modèles ################
########################################################

if (!file.exists("results/reg_morc.RDS")) {
  reg_morc <- lapply(seq_along(all_models), function(i_sect) {
    lapply(seq_along(all_models[[i_sect]]), function(i_mod) {
      mod <- all_models[[i_sect]][[i_mod]]
      bp <- all_bp[[i_sect]][[i_mod]]
      if (all(is.na(bp))) {
        mod
      } else {
        var_fixe = grep("ind", names(coef(mod)))
        if (length(var_fixe) == 0)
          var_fixe = NULL
        piece_reg(mod, break_dates = bp, fixed_var = var_fixe)
      }
    })
  })
  names(reg_morc) <- names(all_models)
  saveRDS(reg_morc, "results/reg_morc.RDS")
} else {
  reg_morc <- readRDS("results/reg_morc.RDS")
}

if (!file.exists("results/reg_loc.RDS")) {
  reg_loc <- lapply(all_models, function(sect) {
    lapply(sect, function(mod) {
      data <- get_data(mod)
      formula <- sprintf("%s ~ .", colnames(data)[1])
      tvReg::tvLM(as.formula(formula),
                  data = data)
    })
  })
  saveRDS(reg_loc, "results/reg_loc.RDS")
} else {
  reg_loc <- readRDS("results/reg_loc.RDS")
}

if (!file.exists("results/reg_morc_loc.RDS")) {
  reg_morc_loc <- lapply(seq_along(all_models), function(i_sect) {
    lapply(seq_along(all_models[[i_sect]]), function(i_mod) {
      mod <- all_models[[i_sect]][[i_mod]]
      bp <- all_bp[[i_sect]][[i_mod]]
      if (all(is.na(bp))) {
        mod
      } else {
        var_fixe = grep("ind", names(coef(mod)))
        if (length(var_fixe) == 0)
          var_fixe = NULL
        piece_reg(
          mod,
          break_dates = bp,
          fixed_var = var_fixe,
          tvlm = TRUE
        )
      }
    })
  })
  names(reg_morc_loc) <- names(all_models)
  saveRDS(reg_morc_loc, "results/reg_morc_loc.RDS")
} else {
  reg_morc_loc <- readRDS("results/reg_morc_loc.RDS")
}

if (!file.exists("results/ssm.RDS")) {
  ssm <- lapply(all_models, function(sect) {
    lapply(sect, function(mod) {
      var <- names(coef(mod))[-1] # On enlève la constante
      fixed_var <- rep(FALSE, length(var))
      # Lorsque la variance est estimée, la valeur initiale n'a pas d'importance
      # Toutefois certaines valeurs conduisent à des erreurs d'estimation
      # ici la valeur de 0.001 ne conduisait pas à des erreurs 
      # (contrairement à 0)
      variance <- rep(0.001, length(var))
      fixed_var[grep("ind", var)] <- TRUE
      variance[grep("ind", var)] <- 0
      ssm_lm(
        mod,
        fixed_var_intercept = FALSE,
        fixed_var_variables = fixed_var,
        var_variables = variance,
        var_intercept = 0.001
      )
    })
  })
  saveRDS(ssm, "results/ssm.RDS")
}

##########################################################
################ Estimation en temps réel ################
##########################################################

# Dernière rupture en 2011T3 :
max(unlist(all_bp), na.rm = TRUE)
first_period_oos <- 60

if (!file.exists("results/lm_oos.RDS")) {
  lm_oos <- lapply(all_models, function(sect) {
    lapply(sect, oos_prev, date = first_period_oos)
  })
  saveRDS(lm_oos, "results/lm_oos.RDS")
  rm(lm_oos)
} 

if (!file.exists("results/reg_morc_oos.RDS")) {
  reg_morc_oos <- lapply(reg_morc, function(sect) {
    lapply(sect, oos_prev, date = first_period_oos)
  })
  saveRDS(reg_morc_oos, "results/reg_morc_oos.RDS")
  rm(reg_morc, reg_morc_oos)
} 

if (!all(file.exists(c("results/reg_loc_oos.RDS", "results/reg_loc_fixed_bw_oos.RDS")))) {
  reg_loc_oos_all <- lapply(reg_loc, function(sect) {
    lapply(sect, oos_prev, fixed_bw = FALSE, date = first_period_oos)
  })
  reg_loc_oos_fixed_bw <- lapply(reg_loc, function(sect) {
    lapply(sect, oos_prev, fixed_bw = TRUE, date = first_period_oos)
  })
  saveRDS(reg_loc_oos_all,
          "results/reg_loc_oos.RDS")
  saveRDS(reg_loc_oos_fixed_bw,
          "results/reg_loc_fixed_bw_oos.RDS")
  rm(reg_loc, reg_loc_oos_all, reg_loc_oos_fixed_bw)
} 

if (!all(file.exists("results/reg_morc_loc_oos.RDS", "results/reg_morc_loc_fixed_bw_oos.RDS"))) {
  reg_morc_loc_oos_all <- lapply(reg_morc_loc, function(sect) {
    lapply(sect, oos_prev, fixed_bw = FALSE, date = first_period_oos)
  })
  reg_morc_loc_oos_fixed_bw <- lapply(reg_morc_loc, function(sect) {
    lapply(sect, oos_prev, fixed_bw = TRUE, date = first_period_oos)
  })
  saveRDS(reg_morc_loc_oos_all,
          "results/reg_morc_loc_oos.RDS")
  saveRDS(reg_morc_loc_oos_fixed_bw,
          "results/reg_morc_loc_fixed_bw_oos.RDS")
  rm(reg_morc_loc, reg_morc_loc_oos_all, reg_morc_loc_oos_fixed_bw)
} 

if (!file.exists("results/ssm_oos.RDS")) {
  ssm_oos <- lapply(all_models, function(sect) {
    lapply(sect, function(mod) {
      var <- names(coef(mod))[-1] # On enlève la constante
      fixed_var <- rep(FALSE, length(var))
      variance <- rep(0.001, length(var))
      fixed_var[grep("ind", var)] <- TRUE
      variance[grep("ind", var)] <- 0
      ssm_lm_oos(
        mod,
        fixed_var_intercept = FALSE,
        fixed_var_variables = fixed_var,
        var_variables = variance,
        date = first_period_oos,
        var_intercept = 0.001
      )
    })
  })
  saveRDS(ssm_oos, "results/ssm_oos.RDS")
  rm(ssm_oos)
} 

