library(dplyr)
library(gt)
all_models <- readRDS("results/ruptures.RDS")
nb_models <- all_models |>
  group_by(Sector) |> 
  mutate(Total = n(),
         `Bai et Perron` = sum(`Bai et Perron` ),
         Hansen = sum(Hansen),
         Sector = recode(
           Sector,
           C = "Industrie manufacturière (C)",
           C1 = 'Agro–alimentaire (C1)',
           C3 = "Biens d'équipement (C3)",
           C4 = "Matériels de transport (C4)",
           C5 = "Autres industries (C5)")) |> 
  select(-c(Model)) |> 
  unique() |> 
  rename(Branche = Sector) |> 
  relocate(Total, .after = Branche)
nb_models
write.csv2(nb_models, "DT/img/nb_models.csv", row.names = FALSE)
# saveRDS(nb_models, "DT/img/nb_models.RDS")

read.csv2("DT/img/nb_models.csv", check.names = FALSE) |> 
  gt(groupname_col = NULL,
     rowname_col = "Branche") |> 
  tab_spanner(columns = 3:4,
              "Nombre de ruptures") |>
  grand_summary_rows(
    fns = list(
      Total ~ sum(.)
    )
  ) |> 
  cols_align(
    align = c("center")
  )  |> 
  cols_align(
    align = c("left"),
    columns = 1
  )

library(dplyr)
is_error <- readRDS("results/is_stats.RDS")
oos_error <- readRDS("results/oos_stats.RDS")

format_tbl_error <- function(
    tab,
    selected_methods = c("reg_morc", "reg_loc", "ssm")
) {
  tab |> 
    group_by(Sector, Model) |> 
    mutate(RMSE = RMSE/RMSE[Method == "lm"],
           MAE = MAE/MAE[Method == "lm"],
           MASE = MASE/MASE[Method == "lm"],
           fixed = ifelse(`Bai et Perron`, "Avec rupture", "Sans rupture")
    ) |> 
    filter(Method %in% selected_methods) |> 
    mutate(Method = factor(Method, levels = selected_methods, ordered = TRUE),
           Method = recode_factor(
             Method, 
             reg_morc = "Rég. par morceaux", 
             reg_loc = "Rég. locale",
             ssm = "Coef. stochastiques (espace-état)"), ordered = TRUE) |> 
    group_by(Method, fixed) |> 
    summarise(Moyenne = mean(RMSE),
              `Moyenne baisse`= mean(RMSE[RMSE < 1]),
              `Moyenne hausse`= mean(RMSE[RMSE > 1]),
              Min = min(RMSE),
              D1 = quantile(RMSE, 0.25),
              Médiane = median(RMSE),
              D3 = quantile(RMSE, 0.75),
              Max = max(RMSE),
              `< 1` = sum(round(RMSE, 2) < 1),
              `= 1`  = sum(round(RMSE, 2) == 1),
              `> 1` = sum(round(RMSE, 2) > 1),
              .groups = 'drop') |> 
    arrange(desc(fixed), Method) 
}
error_table <- is_error |> 
  format_tbl_error() |> 
  mutate(Error = "Dans l'échantillon") |> 
  bind_rows(
    oos_error |> 
      format_tbl_error() |> 
      mutate(Error = "Hors échantillon")
  )  |> 
  arrange(desc(fixed), Error, Method) |> 
  rename(rowname = Method) 
error_table
error_table <- error_table |> 
  select(!c(D1, D3, Médiane, `Moyenne baisse`, `Moyenne hausse`)) 
write.csv2(error_table, "DT/img/error_table.csv", row.names = FALSE)

# saveRDS(error_table, "DT/img/error_table.RDS")

library(gt)

read.csv2("DT/img/error_table.csv", check.names = FALSE)|> 
  gt(groupname_col = c("fixed", "Error")) |> 
  fmt_number(decimals = 2, dec_mark = ",", sep_mark = " ") |> 
  fmt_integer(
    columns = starts_with(c("<", "=", ">"))
  ) |> 
  tab_spanner(columns = starts_with(c("<", "=", ">")),
              "Séries dont RMSE") |> 
  cols_align(
    align = c("center")
  )  |> 
  cols_align(
    align = c("left"),
    columns = "rowname"
  )

