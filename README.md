
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DT-tvcoef

[![Build](https://github.com/inseefrlab/dt-tvcoef/workflows/Dockerize/badge.svg)](https://hub.docker.com/repository/docker/inseefrlab/dt-tvcoef)
[![Onyxia](https://img.shields.io/badge/Launch-Datalab-orange?logo=R)](https://datalab.sspcloud.fr/launcher/ide/rstudio?autoLaunch=false&service.image.custom.enabled=true&service.image.pullPolicy=%C2%ABAlways%C2%BB&service.image.custom.version=%C2%ABinseefrlab%2Fdt-tvcoef%3Alatest%C2%BB&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Finseefrlab%2Fdt-tvcoef%2Fmaster%2F.github%2Fsetup_onyxia.sh%C2%BB)

Ce dépôt contient tous les programmes du document de travail

**Quartier-la-Tente A. (2024)**, *Utilisation de modèles de régression à
coefficients variant dans le temps pour la prévision conjoncturelle*,
Document de travail Insee, G2024/16.

Il est disponible à l’adresse :
<https://www.insee.fr/fr/statistiques/xxx>.

Pour citer cet article :

    @article{inseeDTG202416,
      title={Utilisation de mod{\`e}les de r{\'e}gression à coefficients variant dans le temps pour la pr{\'e}vision conjoncturelle},
      author={Quartier{-la-}Tente, Alain},
      journal={Document de travail Insee},
      number={G2024/16},
      year={2024},
      url={https://github.com/InseeFrLab/DT-tvcoef}
    }

Le package R [tvCoef](https://github.com/InseeFrLab/tvCoef) accompagne
cette étude.

## Installation

Tous les programmes sont en R et ils nécessitent d’avoir une version de
Java SE supérieure ou égale à 17. Pour vérifier la version Java utilisée
par R, utiliser la commande :

``` r
library(rJava)
.jinit()
.jcall("java/lang/System", "S", "getProperty", "java.runtime.version")
```

Si vous n’avez pas de version compatible, vous pouvez par exemple
installer une version portable à partir des liens suivants :

- [Zulu JDK](https://www.azul.com/downloads/#zulu)

- [AdoptOpenJDK](https://adoptopenjdk.net/)

- [Amazon Corretto](https://aws.amazon.com/corretto/)

Pour installer tous les packages il faut avoir le package `renv`
d’installé et une fois le projet chargé il suffit de lancer le code
`renv::restore()`.

Une [image
docker](https://hub.docker.com/repository/docker/inseefrlab/dt-tvcoef)
est également disponible et peut être directement utilisée avec
[Onyxia](https://github.com/InseeFrLab/onyxia-web), la plateforme
*datascience* développée par l’[Insee](https://www.insee.fr/fr/accueil)
en cliquant sur
[![Onyxia](https://img.shields.io/badge/Launch-Datalab-orange?logo=R)](https://datalab.sspcloud.fr/launcher/ide/rstudio?autoLaunch=false&service.image.custom.enabled=true&service.image.pullPolicy=%C2%ABAlways%C2%BB&service.image.custom.version=%C2%ABinseefrlab%2Fdt-tvcoef%3Alatest%C2%BB&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2Finseefrlab%2Fdt-tvcoef%2Fmaster%2F.github%2Fsetup_onyxia.sh%C2%BB).

## Description des programmes

- Les codes, graphiques et tableaux des sections “Modélisation générale
  et tests” et “Description des méthodes” sont directement crées dans le
  fichier `DT/DT-tvcoef.qmd`.

- Le dossier `R/extract_data` contient les programmes permettant de
  récupérer les données utilisées dans le document de travail (et
  intégrées dans le package `tvCoef`).

Les programmes suivants sont utilisés calculer les résultats de la
dernière section “Comparaison générale” :

- `R/1_estimation_modeles.R` estime les 28 modèles utilisés les modèles.

- `R/2A_in_sample_error.R` calcule les erreurs dans l’échantillon.

- `R/2B_out_of_sample_error.R` calcule les erreurs dans l’échantillon.

- `R/3_tables.R` génère les tableaux de résultats.
