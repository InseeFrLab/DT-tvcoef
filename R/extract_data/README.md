## Extraction des données

Ce dossier contient l'ensemble des programmes qui ont permis de télécharger les données utilisées dans le document de travail et stockées dans les bases `gdp` et `manufacturing` du document de travail.

- `R/extract_data/0A_fonctions.R` : contient l'ensemble des fonctions utilisées pour télécharger et trimestrialiser les données.

- `R/extract_data/0B_import_bdf.R` : programme de téléchargement des données issues de la Banque de France.
  Il est pour cela nécessaire d'avoir une clé API pour le client webstat de la Banque de France (voir par exemple la [vignette du package `rwebstat`](https://cran.r-project.org/web/packages/rwebstat/vignettes/rwebstat-vignette.html)).

- `R/extract_data/0C_import_insee.R` : programme de téléchargement des données issues de l'Insee (pour la base `manufacturing`).

- `R/extract_data/1_manufacturing.R` : programme lançant les trois précédents programmes pour télécharger les données utilisées dans la base `manufacturing` et les trimestrialiser.

- `R/extract_data/2_gdp.R` : programme téléchargeant les données utilisées dans la base `gdp` (PIB et climat des affaires France).

