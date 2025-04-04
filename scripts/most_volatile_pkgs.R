library(tidyverse)
args = commandArgs(trailingOnly=TRUE)
infile <- args[1]
outfile <- args[2]

df <- read_csv(infile, col_names = c("pkg", "version", "tool", "artifact", "date")) %>%
	mutate(date = date(as_datetime(date)))

df %>%
    group_by(pkg, artifact, tool) %>%
    summarize(different_versions = n_distinct(version)) %>%
    ungroup() %>%
    slice_max(different_versions, n=10) %>%
    write_csv(outfile)

