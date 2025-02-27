{
  description = "Packaging of Colmap-PCD.";

  # CUDA-enabled nixpkgs cache is available at https://nix-community.cachix.org.
  # See the jobset at https://hydra.nix-community.org/jobset/nixpkgs/cuda.
  # We pin nixpkgs to nixos-unstable-small, following the channel the jobset follows.

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
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
    packages = forAllPkgs (self: pkgs: {
      colmap-pcd = (pkgs.colmap.override {
        # Fixed at COLMAP upstream but not backported to Colmap-PCD.
        # https://github.com/colmap/colmap/issues/1742
        cudaPackages = pkgs.cudaPackages_11;
      }).overrideAttrs (prev: rec {
        pname = "colmap-pcd";
        version = "unstable-2025-01-01";
        buildInputs = (builtins.filter (p: (p.pname or "") != "freeimage") prev.buildInputs) ++ [
          self.freeimage
          pkgs.bzip2
          pkgs.llvmPackages.openmp
          pkgs.lz4
          pkgs.opencv
          pkgs.pcl
        ];
        # C++ standard needs to be explicitly set when using CUDA.
        # PCL requires 201703L or above.
        cmakeFlags = (prev.cmakeFlags or []) ++ [
          "-DCMAKE_CXX_STANDARD=17"
        ];
        src = colmap-pcd;
        meta.platforms = prev.meta.platforms ++ pkgs.lib.platforms.darwin;
      });

      freeimage = pkgs.callPackage ./pkgs/freeimage { };

      default = self.colmap-pcd;
    });
  };
}
