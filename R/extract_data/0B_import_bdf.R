library(rwebstat)
library(dplyr)
webstat_client_ID <- Sys.getenv("webstat_client_ID")

CONJ_series <- w_series_list("CONJ")
CONJ_series <- CONJ_series |> 
  filter(ADJUSTMENT == "S", FREQ == "M", 
         ENQCNJ_TYPE_ENQ == "IN",
         ENQCNJ_SECTEUR %in% c("000CZ",
                               "000C1", "000C3", "000C4", "000C5"))
variables <- c("CCTSM000" = "sitcar",
               "CRTEM100" = "evocar",
               "ICAIN181" = "bc", 
               "PPTEM100" = "prix", 
               "PRTEM100" = "prodpas", 
               "PRTPM100" = "prodpre", 
               "PVTSM000" = "stocks", 
               "TRTSM000" = "tres", 
               "TUTSM000" = "tuc")
CONJ_series = CONJ_series |> filter(ENQCNJ_QUESTION %in% names(variables)) |> 
  mutate(nom_var = sprintf("bdf_%s%s", variables[ENQCNJ_QUESTION],
                           tolower(gsub("_CZ", "", gsub("(^0+)", "_", ENQCNJ_SECTEUR)))))

CONJ <- lapply(CONJ_series$SeriesKey, w_data)

CONJ <- Reduce(\(x,y) merge(x,y, by = "date", all = TRUE), CONJ)

first_date <- as.numeric(c(format(CONJ[,"date"][1],"%Y"),
                           format(CONJ[,"date"][1], "%m")))
CONJ <- ts(CONJ[,-1], start = first_date, frequency = 12)
colnames(CONJ) <- CONJ_series$nom_var

saveRDS(CONJ, "R/extract_data/bdf.RDS")

