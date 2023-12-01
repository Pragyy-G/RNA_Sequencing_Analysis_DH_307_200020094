
---

library(DESeq2)
library(ggplot2)
library(pheatmap)
library(EnhancedVolcano)

packageVersion("DESeq2")

file_path <- "C:\\Users\\ASUS\\DH 307 Reserach Project\\RNA_seq\\GSE1389672_featurecounts.csv"
count_new_data <- read.csv(file_path)
head(count_new_data)
# Remove rows with any missing values
count_new_data <- count_new_data[complete.cases(count_new_data), ]

rownames(count_new_data) <- count_new_data$Genomeid
rownames(count_new_data)
count_new_data <- count_new_data[, -1]

colData <- data.frame(read.csv("C:\\Users\\ASUS\\DH 307 Reserach Project\\RNA_seq\\sample_info.txt"))
rownames(colData)
rownames(colData) <- colData$studyid

all(colnames(count_new_data) %in% row.names(colData))
all(colnames(count_new_data) == row.names(colData))

dds <- DESeqDataSetFromMatrix(countData=count_new_data,
                              colData=colData,
                              design = ~ condition)
dds

keep <- rowSums(counts(dds)) >=5
keep

dds <- dds[keep,]
dds

dds$condition <- relevel(dds$condition, ref = "WHO II")

# Run DESeq function
dds <- DESeq(dds)