source("R/extract_data/0A_fonctions.R")

climat_fr <- "001565530"
pib <- "010565708"
pib <- lectureBDM(pib)
climat_fr <- lectureBDM(climat_fr)

soldes_trim <- trimestrialise(climat_fr)
pib = (pib / stats::lag(pib, -1)-1)*100

data_pib <- ts.union(pib, soldes_trim, diff(soldes_trim, 1))
colnames(data_pib) <- c("pib", sprintf("climat_fr_m%i", 1:3),
                        sprintf("diff_climat_fr_m%i", 1:3))
data_pib <- window(data_pib, start = 2000, end = c(2022,4)
) 
colnames(data_pib) <- c("growth_gdp", "bc_fr_m1", "bc_fr_m2", "bc_fr_m3", "diff_bc_fr_m1", 
                        "diff_bc_fr_m2", "diff_bc_fr_m3")
saveRDS(data_pib, "R/extract_data/data/gdp.RDS")
