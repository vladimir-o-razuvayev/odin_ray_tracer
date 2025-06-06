{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["aarch64-darwin"] (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      odinEnvPackages = [
        pkgs.nixd
        pkgs.alejandra
        pkgs.pre-commit
        pkgs.odin
        pkgs.ols
        pkgs.nix-tree
      ];
    in {
      devShells.default = pkgs.mkShell {
        packages = odinEnvPackages;
      };

      packages.default = pkgs.buildEnv {
        name = "odin-env";
        paths = odinEnvPackages;
      };
    });
}
