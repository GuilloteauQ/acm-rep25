{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.11-pre";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig.bash-prompt = "(\\u@\\h) \\w [dev]\$ ";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              texliveFull
              rubber
              (rWrapper.override { packages = [ rPackages.tidyverse ]; })
              graphviz
              wget
              (aspellWithDicts (d: [ d.en ]))
            ];
          };
        };
      }
	);
}
