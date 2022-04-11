## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---- load-library------------------------------------------------------------
library(rhdf5)

## ---- private-mock-credentials------------------------------------------------
## these are example credentials and will not work
s3_cred <- list(
    aws_region = "eu-central-1",
    access_key_id = "AKIAIOSFODNN7EXAMPLE",
    secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
)

## ---- private-h5ls, eval = FALSE----------------------------------------------
#  public_S3_url <- "https://rhdf5-private.s3.eu-central-1.amazonaws.com/h5ex_t_array.h5"
#  h5ls(file = public_S3_url,
#       s3 = TRUE,
#       s3credentials = s3_cred)

## ----sessioninfo--------------------------------------------------------------
sessionInfo()

