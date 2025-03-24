all: src/main.pdf

ZENODO_URL:=https://zenodo.org/records/15077956/files/europar24.zip

FIGS:=src/figs/workflow.pdf src/figs/results_per_artifact.pdf src/figs/results_per_tool.pdf

ARTIFACTS:=canon_solving geijer_how hiraga_peanuts munoz_fault wolff_fast
DATES:=20241001 20241104 20241201 20250102 20250205 20250312

DATA_PKGS:= $(foreach wrd,$(ARTIFACTS),$(foreach date,$(DATES), data/europar24/pkgs/$(wrd)/$(date).csv))
DATA_BUILD_STATUS:= $(foreach wrd,$(ARTIFACTS),$(foreach date,$(DATES), data/europar24/build_status/$(wrd)/$(date).csv))
DATA_ARTIFACT_HASH:= $(foreach wrd,$(ARTIFACTS),$(foreach date,$(DATES), data/europar24/artifact_hash/$(wrd)/$(date).csv))
# DATA_PKGS := $(foreach wrd,$(ARTIFACTS),$(shell ls -1 data/europar24/pkgs/$(wrd)/ | xargs -I{} echo data/europar24/pkgs/$(wrd)/{}))
# DATA_BUILD_STATUS := $(foreach wrd,$(ARTIFACTS),$(shell ls -1 data/europar24/build_status/$(wrd)/ | xargs -I{} echo data/europar24/build_status/$(wrd)/{}))
# DATA_ARTIFACT_HASH := $(foreach wrd,$(ARTIFACTS),$(shell ls -1 data/europar24/artifact_hash/$(wrd)/ | xargs -I{} echo data/europar24/artifact_hash/$(wrd)/{}))


data/europar24.zip:
	mkdir -p data/ && wget $(ZENODO_URL) -O $@

data/europar24: data/europar24.zip
	unzip -d data/ $^ 

$(DATA_PKGS) $(DATA_BUILD_STATUS) $(DATA_ARTIFACT_HASH): data/europar24
	true

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

