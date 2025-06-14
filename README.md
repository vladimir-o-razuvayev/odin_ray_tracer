# odin_ray_tracer

## Commands

### Local
 - `result/bin/odin_ray_tracer` to execute built app
 - `odin test src` to see full test output even when successful
 - `open -a zed` to launch Zed from dev shell

### Nix
 - `nix develop` to enter dev shell
 - `nix build` - build Odin project
 - `nix eval .#packages.aarch64-darwin.default` to see path to derivation

#### Tree
 - `nix-tree $(nix build .#devShells.aarch64-darwin.default --no-link --print-out-paths)` to see all packages and dependencies for the shell
 - `nix-tree $(nix build .#packages.aarch64-darwin.default --no-link --print-out-paths)` to see all packages and dependencies for the build

#### Flake
 - `nix flake check` to run tests
 - `nix flake show`

### Pre-Commit
 - `pre-commit install`
 - `pre-commit autoupdate`

## Docs

### Errata
 - Before running nix build, make sure to run `git add .` to include all new files
   + Flake inputs do not see files that have not been added

### Darwin
 - See [Darwin (macOS)](https://nixos.org/manual/nixpkgs/stable/#sec-darwin) platform notes in the Nixpkgs Reference Manual.
 - Make sure 'Command Line Tools for Xcode' is up to date
   + Run `softwareupdate --list` to check, and `softwareupdate --install --all` to update
 - See [Darwin stdenv](https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/darwin/README.md)
 - See [Building Odin on MacOS](https://odin-lang.org/docs/install/#macos)

### Nix
 - [stdenv Phases](https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases)
