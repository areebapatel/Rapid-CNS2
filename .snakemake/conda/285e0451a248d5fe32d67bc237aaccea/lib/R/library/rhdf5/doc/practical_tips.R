## ----setup, echo = FALSE, include=FALSE---------------------------------------
library(rhdf5)
library(dplyr)
library(ggplot2)

## ----create data, echo=TRUE, warning=FALSE------------------------------------
m1 <- matrix(rep(1:20000, each = 100), ncol = 20000, byrow = FALSE)
ex_file <- tempfile(fileext = ".h5")
h5write(m1, file = ex_file, name = "counts", level = 6)

## ----extract1, echo = TRUE----------------------------------------------------
system.time(
  res1 <- h5read(file = ex_file, name = "counts", 
                 index = list(NULL, 1:10000))
)

## ----extract2, echo = TRUE----------------------------------------------------
index <- list(NULL, seq(from = 1, to = 20000, by = 2))
system.time(
  res2 <- h5read(file = ex_file, name = "counts", 
                 index = index)
)

## ----extract3, echo = TRUE----------------------------------------------------
start <- c(1,1)
stride <- c(1,2)
block <- c(100,1)
count <- c(1,10000)
system.time(
  res3 <- h5read(file = ex_file, name = "counts", start = start,
                 stride = stride, block = block, count = count)
)
identical(res2, res3)

## ---- eval = TRUE, echo = FALSE, fig.width=6, fig.height=3, fig.wide = TRUE----
## this code demonstrates the exponential increase in time as the 
## number of hyberslab unions increases

select_index <- function(n = 1) {

  ## open the dataspace for the count table
  fid <- H5Fopen(ex_file)
  did  <- H5Dopen(fid, name = "counts")
  sid <- H5Dget_space(did)
  
  ## column choice based on number of unions required
  columns <- c(head(1:10001, n = -n), head(seq(10001-n+2, 20000, 2), n = n-1))
  index <- list(100, columns)
  H5Sselect_index(sid, index = index)
  
  ## tidy up
  H5Sclose(sid)
  H5Dclose(did)
  H5Fclose(fid)
}

bm <- microbenchmark::microbenchmark(
  select_index(1), select_index(2), select_index(5), 
  select_index(10), select_index(20), select_index(50),
  select_index(100), select_index(200), select_index(500),
  select_index(1000), select_index(2000), select_index(5000),
  select_index(10000),
  times = 3
) %>% mutate(n = gsub(".*\\(([0-9]+)\\)", "\\1", expr) 
             %>% as.integer(),
             time = time / 1e9)

ggplot(bm,aes(x = n, y = time)) +
  geom_point() + 
  scale_x_log10() + 
  scale_y_log10() +
  theme_bw() +
  xlab('number of hyperslab unions') +
  ylab('time (seconds)')

## ----singleReads, cached = TRUE-----------------------------------------------
set.seed(1234)
columns <- sample(x = seq_len(20000), size = 10000, replace = FALSE) %>%
  sort()

f1 <- function(cols, name) { 
  h5read(file = ex_file, name = name, 
         index = list(NULL, cols))
  }
system.time(res4 <- vapply(X = columns, FUN = f1, 
                           FUN.VALUE = integer(length = 100), 
                           name = 'counts'))

## ----createChunked, echo = TRUE, eval = TRUE, results='hide'------------------
h5createDataset(file = ex_file, dataset = "counts_chunked", 
                dims = dim(m1), storage.mode = "integer", 
                chunk = c(100,100), level = 6)
h5write(obj = m1, file = ex_file, name = "counts_chunked")

## ----read_chunked, eval = TRUE------------------------------------------------
system.time(res5 <- vapply(X = columns, FUN = f1, 
                           FUN.VALUE = integer(length = 100), 
                           name = 'counts_chunked'))

## -----------------------------------------------------------------------------
f2 <- function(block_size = 100) {
  cols_grouped <- split(columns,  (columns-1) %/% block_size)
  res <-  lapply(cols_grouped, f1, name = 'counts_chunked') %>%
    do.call('cbind', .)
}
system.time(f2())

## ----benchmark, echo = FALSE, cache = TRUE------------------------------------
bm <- microbenchmark::microbenchmark(
  f2(10), f2(25), f2(50), f2(100), 
  f2(250), f2(500), f2(1000), 
  f2(2000), f2(5000), f2(10000),
  times = 3
) %>% mutate(block_size = gsub(".*\\(([0-9]+)\\)", "\\1", expr) 
             %>% as.integer(),
             time = time / 1e9)

## ---- echo = FALSE, fig.width=6, fig.height=3, fig.wide = TRUE----------------
ggplot(bm, aes(x = block_size, y = time)) + 
  geom_point() + 
  scale_x_log10() +
  theme_bw() + 
  ylab('time (seconds)')

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  h5createDataset(file = ex_file, dataset = "counts_chunked", dims = dim(m1),
#                  storage.mode = "integer", chunk = c(100,1), level = 6)
#  h5write(obj = m1, file = ex_file, name = "counts_chunked")
#  f2 <- function(cols) { h5read(file = ex_file, name = 'counts_chunked', index = list(NULL, cols))}
#  system.time(res5 <- vapply(columns, f2, integer(length = 100)))

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  h5createDataset(file = ex_file, dataset = "counts_chunked_100", dims = dim(m1),
#                  storage.mode = "integer", chunk = c(100,100), level = 6)
#  h5write(obj = m1, file = ex_file, name = "counts_chunked_100")
#  
#  f2 <- function(col, fid, dapl, did, sid, mem_sid) {
#      size <- H5Sselect_index(h5space = sid, index = list(NULL, col))
#      res <- H5Dread(did, sid, mem_sid)
#      res
#  }
#  
#  fid <- H5Fopen(ex_file)
#  dapl <- H5Pcreate("H5P_DATASET_ACCESS")
#  did <- H5Dopen(h5loc = fid, name = "counts", dapl = dapl)
#  sid <- H5Dget_space(h5dataset = did)
#  mem_sid <- H5Screate_simple(c(100,1))
#  system.time(res5 <- vapply(columns, f2, integer(length = 100), fid, dapl, did, sid, mem_sid))
#  H5Sclose(sid)
#  H5Sclose(mem_sid)
#  H5Pclose(dapl)
#  H5Dclose(did)
#  H5Fclose(fid)

## ---- echo = FALSE, eval = FALSE----------------------------------------------
#  h5createDataset(file = ex_file, dataset = "counts_chunked", dims = dim(m1),
#                  storage.mode = "integer", chunk = c(100,1), level = 6)
#  h5write(obj = m1, file = ex_file, name = "counts_chunked")
#  
#  f2 <- function(col, fid, dapl, did) {
#      sid <- .Call("_H5Dget_space", did@ID, PACKAGE = "rhdf5")
#      #sid <- H5Dget_space(did)
#      mem_sid <- .Call("_H5Screate_simple", c(100,1), c(100,1), PACKAGE='rhdf5')
#      .Call("_H5Sselect_index", sid, list(col-1,0), list(1,100), PACKAGE='rhdf5')
#      res <- .Call("_H5Dread", did@ID, sid, mem_sid, NULL, TRUE, 0L, FALSE, FALSE, PACKAGE='rhdf5')
#      invisible(.Call("_H5Sclose", sid, PACKAGE='rhdf5'))
#      #H5Sclose(sid)
#      invisible(.Call("_H5Sclose", mem_sid, PACKAGE='rhdf5'))
#      res
#  }
#  
#  fid <- H5Fopen(ex_file)
#  dapl <- H5Pcreate("H5P_DATASET_ACCESS")
#  did <- H5Dopen(h5loc = fid, name = "counts_chunked", dapl = dapl)
#  system.time(res5 <- vapply(columns, f2, double(length = 100), fid, dapl, did))
#  H5Pclose(dapl)
#  H5Dclose(did)
#  H5Fclose(fid)

## ----sessionInfo, echo=FALSE--------------------------------------------------
sessionInfo()

