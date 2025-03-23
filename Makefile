all: src/main.pdf

FIGS:=src/figs/workflow.pdf src/figs/results_per_artifact.pdf src/figs/results_per_tool.pdf

ARTIFACTS:= $(shell ls -1 data/europar24/pkgs)

DATA_PKGS := $(foreach wrd,$(ARTIFACTS),$(shell ls -1 data/europar24/pkgs/$(wrd)/ | xargs -I{} echo data/europar24/pkgs/$(wrd)/{}))
DATA_BUILD_STATUS := $(foreach wrd,$(ARTIFACTS),$(shell ls -1 data/europar24/build_status/$(wrd)/ | xargs -I{} echo data/europar24/build_status/$(wrd)/{}))
DATA_ARTIFACT_HASH := $(foreach wrd,$(ARTIFACTS),$(shell ls -1 data/europar24/artifact_hash/$(wrd)/ | xargs -I{} echo data/europar24/artifact_hash/$(wrd)/{}))

data: data/aggregated/pkgs.csv data/aggregated/build_status.csv data/aggregated/artifact_hash.csv

plop:
	@echo $(DATA_PKGS)

src/main.pdf: src/main.tex src/references.bib $(FIGS)
	cd src && rubber -d main

src/figs/workflow.pdf: src/figs/workflow.dot
	dot -Tpdf $< > $@

src/figs/results_per_artifact.pdf: scripts/results_per_artifact.R data/aggregated/pkgs.csv
	Rscript $^ $@

src/figs/results_per_tool.pdf: scripts/results_per_tool.R data/aggregated/pkgs.csv
	Rscript $^ $@

data/aggregated/pkgs.csv: $(DATA_PKGS)
	mkdir -p data/aggregated && cat $^ > $@

data/aggregated/build_status.csv: $(DATA_BUILD_STATUS)
	mkdir -p data/aggregated && cat $^ > $@

data/aggregated/artifact_hash.csv: $(DATA_ARTIFACT_HASH)
	mkdir -p data/aggregated && cat $^ > $@

