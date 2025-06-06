# odin_ray_tracer

`nix develop` to enter dev shell
`open -a zed` to launch Zed from dev shell
`nix eval .#packages.aarch64-darwin.default` to see path to derivation
`nix flake show`
`nix-tree $(nix build .#devShells.aarch64-darwin.default --no-link --print-out-paths)` to see all packages and dependencies for the shell
`nix-tree $(nix build .#packages.aarch64-darwin.default --no-link --print-out-paths)` to see all packages and dependencies for the shell
`nix build` - build Odin project
