library(tidyverse)
args = commandArgs(trailingOnly=TRUE)
infile <- args[1]
outfile <- args[2]

df <- read_csv(infile, col_names = c("pkg", "version", "tool", "artifact", "date")) %>%
	mutate(date = date(as_datetime(date)))

dates <- df %>% pull(date) %>% unique()

p <- df %>%
	group_by(artifact, tool, pkg) %>%
	arrange(date) %>%
	nest() %>%
	rowwise() %>%
	mutate(data2 = list(data %>% arrange(date) %>% mutate(rank = .$date[match(version, .$version)]))) %>%
	select(-data) %>%
	unnest_wider(data2) %>%
	unnest_longer(c("version", "date", "rank")) %>%
	group_by(artifact, date) %>%
	mutate(total_pkgs = n()) %>%
	group_by(artifact, date, rank, total_pkgs) %>%
	summarize(total = n()) %>%
	mutate(rank = factor(rank)) %>%
	mutate(rank = factor(rank, levels=rev(levels(rank)))) %>%
	ggplot(aes(x = factor(date), y = 100 * total / total_pkgs, fill = rank)) +
	geom_col() +
	geom_text(data = . %>% filter(as.character(rank) == dates[1]), aes(y = (100 * total/total_pkgs) - 5, label = total), angle=0, size=2.0) +
	geom_text(data = . %>% filter(as.character(rank) == dates[1]), aes(y = (100 * total/total_pkgs) - 15, label = paste("(",round(100*total/total_pkgs, digits = 1), "%)",sep="")), angle=0, size=1.25) +
	ylab("Packages in environment [%]") +
	facet_wrap(~artifact, ncol = 5) +
	ggtitle("Evolution of the packages versions over time for each Dockerfile studied") +
	scale_fill_grey("Month when the package version\nwas introduced in the environment", labels=rev(append(c("Initial"), seq(length(dates)-1))))+
	scale_x_discrete("Months after initial build", labels=append(c("Initial"), seq(length(dates)-1))) +
	theme_bw() +
	theme(legend.position = "bottom", strip.background = element_blank()) +
	guides(fill = guide_legend(reverse=TRUE, nrow=1))

ggsave(plot=p,outfile, width=8, height=2.95)
