{
  description = "Packaging of Polmap-PCD.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:usertam/nix-systems";
  };

  outputs = { self, nixpkgs, systems }: let
    forAllSystems = with nixpkgs.lib; genAttrs systems.systems;
    forAllPkgs = pkgsWith: forAllSystems (system: pkgsWith
      (import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "freeimage-unstable-2021-11-01"
        ];
      })
    );
  in {
    packages = forAllPkgs (pkgs: rec {
      default = pkgs.stdenv.mkDerivation {
        name = "polmap-pcd";
        src = pkgs.fetchFromGitHub {
          owner = "XiaoBaiiiiii";
          repo = "colmap-pcd";
          rev = "main";
          hash = "sha256-0Y74ni0zQmxuYgtQKJ+SL5kSxEokan0wf1uUWizD3q8=";
        };
        cmakeFlags = [
          "-DBOOST_STATIC=false"
        ];
        nativeBuildInputs = [ pkgs.cmake ];
        buildInputs = with pkgs; [
          boost
          ceres-solver
          freeimage
          glew
          glfw
          llvmPackages.openmp
          lz4
          opencv
          pcl
          qt5.qtbase
          qt5.wrapQtAppsHook
          sqlite
        ];
      };
    });
  };
}
