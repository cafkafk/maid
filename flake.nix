{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    utils.url = github:numtide/flake-utils;

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    treefmt-nix,
    systems,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        config = {};

        overlay = pkgsNew: pkgsOld: {
          maid =
            pkgsNew.haskell.lib.justStaticExecutables
            pkgsNew.haskellPackages.maid;

          haskellPackages = pkgsOld.haskellPackages.override (old: {
            overrides = pkgsNew.haskell.lib.packageSourceOverrides {
              maid = ./.;
            };
          });
        };

        pkgs = import nixpkgs {
          inherit config system;
          overlays = [overlay];
        };

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        buildInputs = with pkgs; lib.optionals stdenv.isDarwin [libiconv darwin.apple_sdk.frameworks.Security];
      in rec {
        # For `nix fmt`
        formatter = treefmtEval.config.build.wrapper;

        # For `nix flake check`
        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        packages.default = pkgs.haskellPackages.maid;

        apps.default = {
          type = "app";

          program = "${pkgs.maid}/bin/maid";
        };

        devShells.default = pkgs.haskellPackages.maid.env;
      }
    );
}
