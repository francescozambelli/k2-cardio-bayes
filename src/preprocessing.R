# src/preprocessing.R
# Data cleaning, physiological correction, and categorization functions

library(dplyr)

#' Correct physiological recording errors in blood pressure
#'
#' @param name Feature name ('ap_hi' or 'ap_lo')
#' @param data Data frame containing the blood pressure measurements
#' @return Corrected numeric vector
data_corr <- function(name, data) {
  res <- c()
  if (name == 'ap_hi') {
    for (d in data[[name]]) {
      if (d < 30 && d > 5) {
        res <- c(res, d * 10)
      } else if (d < 0) {
        res <- c(res, -d)
      } else if (d > 500 && d < 5000) {
        res <- c(res, d / 10)
      } else if (d > 5000) {
        res <- c(res, d / 100)
      } else {
        res <- c(res, d)
      }
    }
  }
  
  if (name == 'ap_lo') {
    for (d in data[[name]]) {
      if (d < 30 && d > 5) {
        res <- c(res, d * 10)
      } else if (d < 0) {
        res <- c(res, -d)
      } else if (d > 500 && d < 5000) {
        res <- c(res, d / 10)
      } else if (d > 5000) {
        res <- c(res, d / 100)
      } else {
        res <- c(res, d)
      }
    }
  }
  return(res)
}

#' Apply full cleaning pipeline to cardiovascular dataset
#'
#' @param df Raw data frame from CSV
#' @return Cleaned data frame with derived age_year and corrected blood pressure
clean_cardio_data <- function(df) {
  df <- df %>% mutate(age_year = round(age / 365, 0))
  for (n in c("ap_hi", "ap_lo")) {
    df[[n]] <- data_corr(n, df)
  }
  return(df)
}
