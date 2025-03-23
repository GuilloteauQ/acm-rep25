{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.11-pre";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {

      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            gnumake
            texliveFull
            rubber
            (rWrapper.override { packages = [ rPackages.tidyverse ]; })
            graphviz
          ];
        };
      };
    };
}
