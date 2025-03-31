# ACM-REP25 - short paper

URL: https://acm-rep.github.io/2025/cfp/

## How to build

### With Nix

```console
nix develop --command make
```

The pdf will be in `src/main.pdf`.


### Without Nix

You will need:

- GNU Make (4.4.1)

- LaTeX (pdfTeX 3.141592653-2.6-1.40.25)

- `rubber` (1.6.0)

- `R` (4.3.3) with the `tidyverse` (2.0.0) package

- `graphviz` (10.0.1)

- `wget` (1.21.4)


Then run:

```console
make
```

The pdf will be in `src/main.pdf`.
