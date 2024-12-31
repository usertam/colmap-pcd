{
  description = "Packaging of Colmap-PCD.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:usertam/nix-systems";
  };

  outputs = { self, nixpkgs, systems }: let
    forAllSystems = with nixpkgs.lib; genAttrs systems.systems;
    forAllPkgs = pkgsWith: forAllSystems (system: pkgsWith
      self.packages.${system}
      (import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "freeimage-unstable-2024-04-18"
        ];
      })
    );
  in {
    packages = forAllPkgs (pkgs': pkgs: {
      colmap-pcd = pkgs.colmap.overrideAttrs (prev: rec {
        pname = "colmap-pcd";
        version = "unstable-2025-01-01";
        buildInputs = (builtins.filter (pkg: pkg.pname != "freeimage") prev.buildInputs) ++ [
          pkgs'.freeimage
          pkgs.bzip2
          pkgs.llvmPackages.openmp
          pkgs.lz4
          pkgs.opencv
          pkgs.pcl
        ];
        src = pkgs.fetchFromGitHub {
          owner = "XiaoBaiiiiii";
          repo = pname;
          rev = "9cd7d9b7f257306483dc6ecc95d4ef447335888d";
          hash = "sha256-0Y74ni0zQmxuYgtQKJ+SL5kSxEokan0wf1uUWizD3q8=";
        };
        meta.platforms = prev.meta.platforms ++ pkgs.lib.platforms.darwin;
      });

      freeimage = pkgs.callPackage ./pkgs/freeimage {
        inherit (pkgs.darwin) autoSignDarwinBinariesHook;
      };

      default = pkgs'.colmap-pcd;
    });
  };
}
