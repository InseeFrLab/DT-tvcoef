if(!file.exists("R/extract_data/bdf.RDS"))
  source("R/extract_data/0A_import_bdf.R")

if(any(!file.exists("R/extract_data/prod.RDS"), !file.exists("R/extract_data/soldes_insee.RDS")))
  source("R/extract_data/0B_import_insee.R")

source("R/extract_data/0A_fonctions.R")
bdf <- readRDS("R/extract_data/bdf.RDS")
prod <- readRDS("R/extract_data/prod.RDS")
soldes_insee <- readRDS("R/extract_data/soldes_insee.RDS")

ipi <- readRDS("R/extract_data/ipi.RDS")
ipi_trim <- rjd3toolkit::aggregate(ipi, nfreq = 4, "Sum")
acquis_ipi0 <- ts((ipi*3)[c(FALSE,FALSE,TRUE),],start=c(1990,2),freq=4)
acquis_ipi1 <- ts((ipi*3)[c(TRUE,FALSE,FALSE),],start=c(1990,1),freq=4)
acquis_ipi2 <- ts((ipi*2+stats::lag(ipi,-1))[c(TRUE,FALSE,FALSE),],start=c(1990,1),freq=4)
tct_acquis_ipi0 <- ((acquis_ipi0/stats::lag(ipi_trim,-1)-1)*100)
tct_acquis_ipi1 <- ((acquis_ipi1/stats::lag(ipi_trim,-1)-1)*100)
tct_acquis_ipi2 <- ((acquis_ipi2/stats::lag(ipi_trim,-1)-1)*100)
acquis_ipi <- ts.union(tct_acquis_ipi0, tct_acquis_ipi1, tct_acquis_ipi2)
colnames(acquis_ipi) <- sprintf("acquis_ipi%i%s",
                                rep(c(0, 1, 2), each= ncol(ipi)),
                                rep(gsub("(ipi)|(_manuf)", "", colnames(ipi)), 3))

soldes_mens <- ts.union(soldes_insee, bdf)
colnames(soldes_mens) <- c(colnames(soldes_insee),
                           colnames(bdf))
soldes_trim <- trimestrialise(soldes_mens)
prod <- (prod / stats::lag(prod, -1)-1)*100
colnames(prod) <- gsub("^prod.", "", colnames(prod))
data <- ts.union(prod, acquis_ipi, soldes_trim)
ind <- cbind(time(data) == 2008.75,
            time(data) == 2009,
            time(data) == 1997.25,
            time(data) == 2011,
            time(data) == 2012.5,
            time(data) == 2013.75,
            time(data) == 2020,
            time(data) == 2020.25,
            time(data) == 2020.50,
            time(data) == 2020.75,
            time(data) == 2021,
            time(data) == 2021.25,
            time(data) == 2021.50,
            time(data) == 2021.75)
colnames(ind) <- c("ind2008Q4", "ind2009Q1",
                  "ind1997Q2", "ind2011Q1",
                  "ind2012Q3", "ind2013Q3",
                  "ind2020Q1", "ind2020Q2",
                  "ind2020Q3", "ind2020Q4",
                  "ind2021Q1", "ind2021Q2",
                  "ind2021Q3", "ind2021Q4")
data <- ts.union(data, ind)
colnames(data) <- c(colnames(prod), colnames(acquis_ipi), colnames(soldes_trim),
                    colnames(ind))
saveRDS(data, "R/extract_data/manufacturing.RDS")
