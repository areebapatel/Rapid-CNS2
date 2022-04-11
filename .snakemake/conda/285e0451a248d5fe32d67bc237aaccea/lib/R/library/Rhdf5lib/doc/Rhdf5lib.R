## ----headers------------------------------------------------------------------
system.file(package="Rhdf5lib", "include")

## ---- zlib-path, eval = FALSE-------------------------------------------------
#  BiocManager::install('Rhdf5lib', configure.args = "--with-zlib='/path/to/zlib/'")

## ---- disable-lto, eval = FALSE-----------------------------------------------
#  BiocManager::install('Rhdf5lib', INSTALL_opts="--no-use-LTO", configure.args = "--disable-lto")

## ----sessionInfo, echo=FALSE--------------------------------------------------
sessionInfo()

