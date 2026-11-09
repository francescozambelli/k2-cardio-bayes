# install.R
# Script to install all required packages for ASPACARDIO

cran_packages <- c(
  "tidyverse",
  "bnlearn",
  "caret",
  "randomForest",
  "gtools",
  "ROCR",
  "rpart",
  "rpart.plot",
  "rattle",
  "curl"
)

new_cran <- cran_packages[!(cran_packages %in% installed.packages()[, "Package"])]
if (length(new_cran) > 0) {
  install.packages(new_cran, repos = "https://cloud.r-project.org")
}

# Install Bioconductor dependency for graph plotting in bnlearn
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

if (!("Rgraphviz" %in% installed.packages()[, "Package"])) {
  BiocManager::install("Rgraphviz", update = FALSE, ask = FALSE)
}

message("All dependencies installed successfully.")
