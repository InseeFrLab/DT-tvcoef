trimestrialise = function(x, prefixe_series = NULL)
{
  UseMethod("trimestrialise")
}
trimestrialise.ts = function(x, prefixe_series = NULL)
{
  if(frequency(x)!=12)
    stop("Il faut que la série à trimestrialiser soit mensuelle !")
  
  date_debut_trim<-c(start(x)[1],(start(x)[2]-1)%/%3+1)
  series_mens<-window(x,start=date_debut_trim,extend=T)
  
  
  if(is.null(prefixe_series)){
    prefixe_series<-deparse(substitute(x))
  }else{
    if(length(prefixe_series)!=1)
      stop("Il faut autant des préfixes que de séries à trimestrialiser !")
  }
  
  series_m1<-ts(series_mens[cycle(series_mens)%in%c(1,4,7,10)],start=date_debut_trim,frequency = 4)
  series_m2<-ts(series_mens[cycle(series_mens)%in%c(2,5,8,11)],start=date_debut_trim,frequency = 4)
  series_m3<-ts(series_mens[cycle(series_mens)%in%c(3,6,9,12)],start=date_debut_trim,frequency = 4)
  
  series_trim<-ts.union(series_m1,series_m2,series_m3)
  colnames(series_trim)<-paste(rep(prefixe_series,3),1:3,sep="_m")
  
  return(series_trim)
}

trimestrialise.mts = function(x, prefixe_series = NULL)
{
  if(frequency(x)!=12)
    stop("Il faut que les séries à trimestrialiser soient mensuelles !")
  
  date_debut_trim<-c(start(x)[1],(start(x)[2]-1)%/%3+1)
  series_mens<-window(x,start=date_debut_trim,extend=T)
  
  
  if(is.null(prefixe_series)){
    prefixe_series<-colnames(x)
  }else{
    if(length(prefixe_series)!=dim(x)[2])
      stop("Il faut autant des préfixes que de séries à trimestrialiser !")
  }
  
  series_m1<-ts(series_mens[cycle(series_mens)%in%c(1,4,7,10),],start=date_debut_trim,frequency = 4)
  series_m2<-ts(series_mens[cycle(series_mens)%in%c(2,5,8,11),],start=date_debut_trim,frequency = 4)
  series_m3<-ts(series_mens[cycle(series_mens)%in%c(3,6,9,12),],start=date_debut_trim,frequency = 4)
  
  series_trim<-ts.union(series_m1,series_m2,series_m3)
  colnames(series_trim)<-paste(rep(prefixe_series,3),rep(1:3,each=length(prefixe_series)),sep="_m")
  return(series_trim)
}

lectureBDM <- function (idbank, ...) 
{
  idbank <- gsub(" ", "", c(idbank, unlist(list(...))))
  UrlData <- paste0("https://bdm.insee.fr/series/sdmx/data/SERIES_BDM/", 
                    paste(idbank, collapse = "+"))
  tryCatch({
    dataBDM <- as.data.frame(rsdmx::readSDMX(UrlData, isURL = T), 
                             stringsAsFactors = TRUE)
  }, error = function(e) {
    stop(paste0("Il y a une erreur dans le téléchargement des données. Vérifier le lien\n", 
                UrlData), call. = FALSE)
  })
  FREQ <- levels(factor(dataBDM$FREQ))
  if (length(FREQ) != 1) 
    stop("Les séries ne sont pas de la même périodicité !")
  freq <- switch(FREQ, M = 12, B = 6, T = 4, S = 2, A = 1)
  sepDate <- switch(FREQ, M = "-", B = "-B", T = "-Q", S = "-S", 
                    A = " ")
  dataBDM <- reshape2::dcast(dataBDM, "TIME_PERIOD ~ IDBANK", 
                             value.var = "OBS_VALUE")
  dataBDM <- dataBDM[order(dataBDM$TIME_PERIOD), ]
  dateDeb <- dataBDM$TIME_PERIOD[1]
  dateDeb <- regmatches(dateDeb, gregexpr(sepDate, dateDeb), 
                        invert = T)[[1]]
  dateDeb <- as.numeric(dateDeb)
  dataBDM$TIME_PERIOD <- NULL
  dataBDM <- apply(dataBDM, 2, as.numeric)
  if (ncol(dataBDM) != length(idbank)) 
    warning(paste("Le ou les idbank suivant n'existent pas :", 
                  paste(grep(paste(colnames(dataBDM), collapse = "|"), 
                             idbank, value = T, invert = T), collapse = ", ")))
  if (ncol(dataBDM) > 1) {
    idbank <- idbank[idbank %in% colnames(dataBDM)]
    dataBDM <- dataBDM[, idbank]
  }
  dataBDM <- ts(dataBDM, start = dateDeb, frequency = freq)
  return(dataBDM)
}