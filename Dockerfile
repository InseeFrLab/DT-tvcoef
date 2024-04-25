# Base image
FROM inseefrlab/onyxia-rstudio:r4.2.2

# Install required linux librairies for rjd3filters
RUN apt-get update --yes && \
    apt-get install --yes libprotoc-dev libprotobuf-dev protobuf-compiler openjdk-17-jdk && \
    R CMD javareconf

ENV RENV_VERSION 1.0.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR ${HOME}/DT-tvcoef
COPY renv.lock renv.lock

ENV RENV_PATHS_LIBRARY renv/library

RUN R -e "renv::restore()"