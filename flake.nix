{
  description = "Ray Tracer Challenge in Odin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: (flake-utils.lib.eachSystem ["aarch64-darwin"] (
    system: let
      pkgs = import nixpkgs {inherit system;};
      odin = pkgs.callPackage ./nix/odin.nix {};
      raytracer = pkgs.callPackage ./nix {inherit odin;};
    in {
      packages.default = raytracer;
      devShells.default = pkgs.callPackage ./nix/shell.nix {inherit odin;};
      checks.default = raytracer;
    }
  ));
}
