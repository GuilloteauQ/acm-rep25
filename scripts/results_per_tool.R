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
	group_by(tool, date) %>%
	mutate(total_pkgs = n()) %>%
	group_by(tool, date, rank, total_pkgs) %>%
	summarize(total = n()) %>%
	mutate(rank = factor(rank)) %>%
	mutate(rank = factor(rank, levels=rev(levels(rank)))) %>%
	ggplot(aes(x = factor(date), y = 100 * total / total_pkgs, fill = rank)) +
	geom_col() +
	geom_text(data = . %>% filter(as.character(rank) == dates[1]), aes(y = (100 * total/total_pkgs) - 5, label = total), angle=0, size=2.0) +
	geom_text(data = . %>% filter(as.character(rank) == dates[1]), aes(y = (100 * total/total_pkgs) - 15, label = paste("(",round(100*total/total_pkgs, digits = 1), "%)",sep="")), angle=0, size=1.5) +
	ylab("Packages in environment [%]") +
	facet_wrap(~tool, ncol = 2) +
	ggtitle("Evolution of the packages versions through time") +
	scale_fill_grey("Month when the package version was introduced in the environment", labels=rev(append(c("Initial"), seq(length(dates)-1))))+
	scale_x_discrete("Months after initial build", labels=append(c("Initial"), seq(length(dates)-1))) +
	guides(fill = guide_legend(reverse=TRUE, nrow=1, title.position ="top", theme = theme(
	  legend.title = element_text(size = 9.2)
	  ))) +
	theme_bw() +
        theme(legend.position = "bottom", strip.background = element_blank(),
          plot.title.position = "plot",
          plot.caption.position =  "plot",
          legend.location = "plot")

ggsave(plot=p,outfile, width=4, height=3.75)
