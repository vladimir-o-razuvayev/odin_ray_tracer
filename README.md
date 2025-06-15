# odin_ray_tracer

## Commands

### Local
 - `result/bin/odin_ray_tracer` to execute built app
 - `odin test src` to see full test output even when successful
 - `odin doc src` to print out docs
 - `zeditor .` to launch Zed from dev shell and open the project

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

#### Profile
 - `nix profile install nixpkgs#kitty` to install kitty to `~/.nix-profile/bin/kitty`
 - `nix profile install nixpkgs#zed-editor` to install Zed to `~/.nix-profile/bin/kitty`
 - `~/.nix-profile` is a symlink to your nix store profile
 - In `~/.nix-profile` create folders `bin` and `Applications` These are not symlinks
 - `nix profile list` to see installed applications and their directories
 - Using the real addresses, create symlinks to the contents. This should work automatically, but it did not for me.
  + E.g., `sudo ln -s /nix/store/zn...lp-zed-editor-0.189.5/Applications/Zed.app /nix/store/h2...54-profile/Applications/Zed.app`

### Pre-Commit
 - `pre-commit install`
 - `pre-commit autoupdate`

## Docs

### Odin
 - Current Odin Version: [dev-2025-06](https://github.com/odin-lang/Odin/tree/dev-2025-06)
 - [Odin Overview](https://odin-lang.org/docs/overview/)
 - [Odin Nix Package](https://github.com/NixOS/nixpkgs/tree/master/pkgs/by-name/od/odin)
 - [Odin Package Nix Shell](https://github.com/odin-lang/Odin/tree/dev-2025-06/shell.nix)
 - Use flag `-target:"?"` to print all supported targets

### Errata
 - Before running nix build, make sure to run `git add .` to include all new files
   + Flake inputs do not see files that have not been added
 - When updating Odin version:
   + Remember to regenerate the patch
   + Delete the Sha in `nix/odin.nix` so that when running `nix build` the correct Sha is printed.

### Darwin
 - See [Darwin (macOS)](https://nixos.org/manual/nixpkgs/stable/#sec-darwin) platform notes in the Nixpkgs Reference Manual.
 - Make sure 'Command Line Tools for Xcode' is up to date
   + Run `softwareupdate --list` to check, and `softwareupdate --install --all` to update
 - See [Darwin stdenv](https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/darwin/README.md)
 - See [Building Odin on MacOS](https://odin-lang.org/docs/install/#macos)

### Nix
 - [stdenv Phases](https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases)
