{
  description = "reproducing a gomod2nix failure";
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    flake-utils.url = github:numtide/flake-utils;

    nix-filter.url = github:numtide/nix-filter;

    flake-compat.url = github:edolstra/flake-compat;
    flake-compat.flake = false;

    gomod2nix.url = "github:nix-community/gomod2nix";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, flake-compat, gomod2nix }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [
            gomod2nix.overlays.default
          ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        rec {
          packages = rec {
            default = broken;
            broken = pkgs.buildGoApplication {
              checkPhase = false;
              pname = "demo";
              version = "0.0.1";
              src = ./.;
              modules = ./gomod2nix.toml;
            };
            working = pkgs.buildGoModule {
              pname = "demo";
              version = "0.0.1";
              # vendorSha256 = pkgs.lib.fakeSha256;
              vendorSha256 = "sha256-eCdtBHDklIwIooXONT5by+fjbTiA+UQOTzBcFwbGiv4=";
              src = nix-filter.lib.filter {
                root = ./.;
                include = [
                  "main.go"
                  "go.mod"
                  "go.sum"
                ];
              };
            };
          };

          apps = rec {
            default = broken;
            broken = {
              type = "app";
              program = "${packages.demo}/bin/demo";
            };
            working = {
              type = "app";
              program = "${packages.working}/bin/working";
            };
          };

          devShells = rec {
            default = pkgs.mkShell {
              packages = with pkgs; [
                go
                pkgs.gomod2nix
              ];
            };
          };
        }
      );
}
