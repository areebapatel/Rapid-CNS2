var_file <- read.csv(snakemake@wildcards[["in_file"]])

no_na <- var_file[which(var_file$cosmic68 != "." | var_file$X1000g2015aug_eur != "." | var_file$Func.refGene == "upstream"),]
cosmic <- no_na[which(no_na$cosmic68 != "." | no_na$X1000g2015aug_eur < 0.01 | no_na$Func.refGene == "upstream"),]

no_syn <- cosmic[which(cosmic$ExonicFunc.refGene != "synonymous SNV"),]

no_syn <- no_syn[order(no_syn$X1000g2015aug_eur),]

table <- no_syn[which(no_syn$X1000g2015aug_eur < 0.01),c("Chr","Start","End","Ref","Alt","Func.refGene","Gene.refGene","ExonicFunc.refGene","AAChange.refGene","cytoBand","avsnp147","X1000g2015aug_eur","cosmic68" )]

write.csv(table,file = snakemake@wildcards[["in_file"]])
