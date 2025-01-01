{
  description = "Packaging of Colmap-PCD.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:usertam/nix-systems";
    colmap-pcd.url = "github:XiaoBaiiiiii/colmap-pcd";
    colmap-pcd.flake = false;
  };

  outputs = { self, nixpkgs, systems, colmap-pcd }: let
    forAllSystems = with nixpkgs.lib; genAttrs systems.systems;
    forAllPkgs = pkgsWith: forAllSystems (system: pkgsWith
      self.packages.${system}
      (import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "freeimage-unstable-2024-04-18"
        ];
        config.allowUnfree = true;
        config.cudaSupport = nixpkgs.legacyPackages.${system}.hostPlatform.isLinux;
      })
    );
  in {
    packages = forAllPkgs (pkgs': pkgs: {
      colmap-pcd = pkgs.colmap.overrideAttrs (prev: rec {
        pname = "colmap-pcd";
        version = "unstable-2025-01-01";
        buildInputs = (builtins.filter (pkg: (pkg.pname or "") != "freeimage") prev.buildInputs) ++ [
          pkgs'.freeimage
          pkgs.bzip2
          pkgs.llvmPackages.openmp
          pkgs.lz4
          pkgs.opencv
          pkgs.pcl
        ];
        src = colmap-pcd;
        meta.platforms = prev.meta.platforms ++ pkgs.lib.platforms.darwin;
      });

      freeimage = pkgs.callPackage ./pkgs/freeimage { };

      default = pkgs'.colmap-pcd;
    });
  };
}
