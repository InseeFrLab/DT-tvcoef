# DT-tvcoef

Ce dépôt contient tous les programmes du document de travail

**Quartier-la-Tente A (2024)**, *Utilisation de modèles de régression à coefficients variant dans le temps pour la prévision conjoncturelle*, Document de travail Insee, G2024/XX.

Pour citer cet article :

    @article{inseeDTG2024XX,
      title={Estimation en temps r{\'e}el de la tendance cycle{ :} apport de l’utilisation de moyennes mobiles asym{\'e}triques},
      author={Quartier{-la-}Tente, Alain},
      journal={Document de travail Insee},
      number={G2024/XX},
      year={2024},
      url={https://github.com/InseeFrLab/DT-tvcoef}
    }

## Installation

Tous les programmes sont en R et ils nécessitent d’avoir une version de Java SE supérieure ou égale à 17. 
Pour vérifier la version Java utilisée
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

Une [image
docker](https://hub.docker.com/repository/docker/aqlt/dt-est-tr-tc) est
également disponible et peut être directement utilisée avec
[Onyxia](https://github.com/InseeFrLab/onyxia-web), la plateforme
*datascience* développée par l’[Insee](https://www.insee.fr/fr/accueil)
en cliquant sur
[![Onyxia](https://img.shields.io/badge/Launch-Datalab-orange?logo=R)](https://datalab.sspcloud.fr/launcher/ide/rstudio?autoLaunch=false&service.image.custom.enabled=true&service.image.pullPolicy=%C2%ABAlways%C2%BB&service.image.custom.version=%C2%ABaqlt%2Fdt-est-tr-tc%3Alatest%C2%BB).

