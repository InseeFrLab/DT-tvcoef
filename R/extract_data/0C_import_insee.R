source("R/extract_data/0A_fonctions.R")
idbank_soldes <- c(
  insee_bc = "001585934", insee_bc_c1 = "001786503", 
  insee_bc_c3 = "001786504", insee_bc_c4 = "001786505", 
  insee_bc_c5 = "001786506", insee_oscd = "001585942", 
  insee_oscd_c1 = "001585944", insee_oscd_c3 = "001585946", 
  insee_oscd_c4 = "001585948", insee_oscd_c5 = "001585950", 
  insee_tppa = "001586064", insee_tppa_c1 = "001586066", insee_tppa_c3 = "001586068", 
  insee_tppa_c4 = "001586070", insee_tppa_c5 = "001586072", 
  insee_tppre = "001586103", insee_tppre_c1 = "001586105", 
  insee_tppre_c3 = "001586107", insee_tppre_c4 = "001586109", 
  insee_tppre_c5 = "001586111")
idbank_prod <- c(
  "manuf_prod" = "010564423",
  "prod_c1" = "010564391",
  "prod_c3" = "010564395",
  "prod_c4" = "010564397",
  "prod_c5" = "010564399")
idbank_ipi <- c(
  "ipi_manuf" = "010537946",
  "ipi_c1" = "010537906",
  "ipi_c3" = "010537910",
  "ipi_c4" = "010537912",
  "ipi_c5" = "010537914")
soldes <- lectureBDM(idbank_soldes)
colnames(soldes) <- names(idbank_soldes)
prod <- lectureBDM(idbank_prod)
colnames(prod) <- names(idbank_prod)
ipi <- lectureBDM(idbank_ipi)
colnames(ipi) <- names(idbank_ipi)
saveRDS(prod, "R/extract_data/prod.RDS")
saveRDS(ipi, "R/extract_data/ipi.RDS")
saveRDS(soldes, "R/extract_data/soldes_insee.RDS")
