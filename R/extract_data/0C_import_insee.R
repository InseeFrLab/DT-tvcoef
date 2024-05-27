source("R/extract_data/0A_fonctions.R")
idbank_soldes <- c(ins_climat = "001585934", ins_climat_c1 = "001786503", 
                   ins_climat_c3 = "001786504", ins_climat_c4 = "001786505", 
                   ins_climat_c5 = "001786506", ins_oscd = "001585942", 
                   ins_oscd_c1 = "001585944", ins_oscd_c3 = "001585946", 
                   ins_oscd_c4 = "001585948", ins_oscd_c5 = "001585950", 
                   ins_tppa = "001586064", ins_tppa_c1 = "001586066", ins_tppa_c3 = "001586068", 
                   ins_tppa_c4 = "001586070", ins_tppa_c5 = "001586072", 
                   ins_tppre = "001586103", ins_tppre_c1 = "001586105", 
                   ins_tppre_c3 = "001586107", ins_tppre_c4 = "001586109", 
                   ins_tppre_c5 = "001586111")
idbank_prod <- c("prod_manuf" = "010564423",
                 "prod_c1" = "010564391",
                 "prod_c3" = "010564395",
                 "prod_c4" = "010564397",
                 "prod_c5" = "010564399")
idbank_ipi <- c("ipi_manuf" = "010537946",
                 "ipi_c1" = "010537906",
                 "ipi_c3" = "010537910",
                 "ipi_c4" = "010537912",
                 "ipi_c5" = "010537914")
soldes = lectureBDM(idbank_soldes)
colnames(soldes) <- names(idbank_soldes)
prod <- lectureBDM(idbank_prod)
colnames(prod) <- names(idbank_prod)
ipi <- lectureBDM(idbank_ipi)
colnames(ipi) <- names(idbank_ipi)
saveRDS(prod, "R/extract_data/prod.RDS")
saveRDS(ipi, "R/extract_data/ipi.RDS")
saveRDS(soldes, "R/extract_data/soldes_insee.RDS")
