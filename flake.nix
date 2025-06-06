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
      clang = pkgs.llvmPackages_16.clang-unwrapped;
      llvm = pkgs.llvmPackages_16.llvm;
      odinEnvPackages = [
        pkgs.nixd
        pkgs.alejandra
        pkgs.pre-commit
        pkgs.odin
        pkgs.ols
        pkgs.nix-tree
        clang
        llvm
      ];
    in {
      devShells.default = pkgs.mkShell {
        packages = odinEnvPackages;
        src = ./.;
        nativeBuildInputs = [pkgs.odin clang llvm];
        buildPhase = ''
          mkdir -p bin
          odin build src -out:bin/hello -llvm-config ${llvm}/bin/llvm-config
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp bin/hello $out/bin/
        '';
      };

      packages.default = pkgs.buildEnv {
        name = "odin-env";
        paths = odinEnvPackages;
      };
    });
}
