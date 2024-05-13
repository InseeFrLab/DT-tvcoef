library(dplyr)
library(ggplot2)
is_error <- readRDS("results/is_stats.RDS")
oos_error <- readRDS("results/oos_stats.RDS")

selected_methods <- c("reg_loc", "reg_morc", "ssm")
is_error |> 
  group_by(Method, `Bai et Perron`) |> 
  summarise(mean = mean(MASE))

is_error |> 
  group_by(Sector, Model) |> 
  mutate(RMSE = RMSE/RMSE[Method == "lm"],
         MAE = MAE/MAE[Method == "lm"],
         MASE = MASE/MASE[Method == "lm"]
  ) |> 
  filter(Method != "lm") |> 
  group_by(Method, `Bai et Perron`) |> 
  summarise(mean = mean(MASE))

oos_error |> 
  group_by(Sector, Model) |> 
  mutate(RMSE = RMSE/RMSE[Method == "lm"],
         MAE = MAE/MAE[Method == "lm"],
         MASE = MASE/MASE[Method == "lm"],
         fixed = ifelse(`Bai et Perron`, "Fixé", "Mobile")
  ) |> 
  filter(Method %in% selected_methods) |> 
  ungroup() |> 
  group_by(Method, fixed) |> 
  summarise(mean = mean(MASE),
            min = min(MASE),
            D1 = quantile(MASE, 0.25),
            med = median(MASE),
            D3 = quantile(MASE, 0.75),
            max = max(MASE),
            `< 1` = sum(round(MASE, 2) < 1),
            `= 1`  = sum(round(MASE, 2) == 1),
            `> 1` = sum(round(MASE, 2) > 1)) |> 
  arrange(fixed, Method)

format_tbl_error <- function(tab) {
  tab |> 
    group_by(Sector, Model) |> 
    mutate(RMSE = RMSE/RMSE[Method == "lm"],
           MAE = MAE/MAE[Method == "lm"],
           MASE = MASE/MASE[Method == "lm"],
           fixed = ifelse(`Bai et Perron`, "Pas de rupture", "Rupture détectée")
    ) |> 
    filter(Method %in% selected_methods) |> 
    mutate(Method = recode(Method, reg_loc = "Rég. locale", reg_morc = "Régr. par morceaux", ssm = "Modèle espace-état")) |> 
    group_by(Method, fixed) |> 
    summarise(mean = mean(RMSE),
              min = min(RMSE),
              D1 = quantile(RMSE, 0.25),
              med = median(RMSE),
              D3 = quantile(RMSE, 0.75),
              max = max(RMSE),
              `< 1` = sum(round(RMSE, 2) < 1),
              `= 1`  = sum(round(RMSE, 2) == 1),
              `> 1` = sum(round(RMSE, 2) > 1),
              .groups = 'drop') |> 
    arrange(fixed, Method)
}
is_error |> 
  format_tbl_error() |> 
  mutate(Error = "Dans l'échantillon") |> 
  bind_rows(
    oos_error |> 
      format_tbl_error() |> 
      mutate(Error = "Hors échantillon")
  )


oos_error |> 
  group_by(Method, fixed) |> 
  summarise(mean = mean(MASE))

ggplot(is_error |> 
         group_by(Sector, Model) |> 
         mutate(RMSE = RMSE/RMSE[Method == "lm"],
                MAE = MAE/MAE[Method == "lm"],
                MASE = MASE/MASE[Method == "lm"]
         ) |> 
         filter(Method != "lm"), aes(x = Method, y = MASE)) +
  geom_boxplot() +
  facet_wrap(vars(fixed), ncol = 1,scales = "free")

ggplot(oos_error |> 
         group_by(Sector, Model) |> 
         mutate(RMSE = RMSE/RMSE[Method == "lm"],
                MAE = MAE/MAE[Method == "lm"],
                MASE = MASE/MASE[Method == "lm"]
         ) |> 
         filter(Method != "lm"), aes(x = Method, y = MASE)) +
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) + 
  geom_jitter() +
  facet_wrap(vars(fixed), ncol = 1,scales = "free")

