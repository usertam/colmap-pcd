# Nix packaging of Colmap-PCD

[![Build](https://github.com/usertam/colmap-pcd/actions/workflows/build.yml/badge.svg)](https://github.com/usertam/colmap-pcd/actions/workflows/build.yml)

Packaging of the fork [XiaoBaiiiiii/colmap-pcd](https://github.com/XiaoBaiiiiii/colmap-pcd) of the original [colmap](https://github.com/colmap/colmap). A more recent packaging of freeimage is included in `pkgs/freeimage`, attempt to upstream [here](https://github.com/NixOS/nixpkgs/pull/369766). Based on the upstream packaging of [colmap](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/misc/colmap/default.nix).

I need to build this for my university final year project. It also helps me procrastinate on the actual project.

## Open nix shell from source
```sh
nix shell github:usertam/colmap-pcd
```

## With binary cache
Use `sudo` only to elevate you to trusted user in nix.
```sh
sudo nix shell github:usertam/colmap-pcd \
  --extra-substituters 'https://colmap-pcd.cachix.org' \
  --extra-trusted-public-keys 'colmap-pcd.cachix.org-1:Vjom1FugFkb8cUORejZqkXDYOe4kulPoXrDdE+/l2hA='
```

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
