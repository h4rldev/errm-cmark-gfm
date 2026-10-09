{
  description = "Errm.. cmark-gfm, a wrapper for cmark-gfm for rendering GFM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    beamPackages = pkgs.beamPackages;

    errm-prod = beamPackages.buildRebar3 {
      name = "errm-cmark-gfm";
      version = "0.1.0-prod";

      src = ./.;

      nativeBuildInputs = with pkgs; [
        pkg-config just
      ];

      preBuild = ''
        sed -i 's|#!/usr/bin/env bash|#!${pkgs.bash}/bin/bash|' justfile
      '';

      buildInputs = with pkgs; [
        cmark-gfm
      ];

      env = {
        REBAR_PROFILE = "prod";
        ERL_ROOT = "${beamPackages.erlang}/lib/erlang/";
        dontUseJustBuild = "1";
        dontUseJustInstall = "1";
        dontUseJustCheck = "1";
      };
    };

    errm-debug = beamPackages.buildRebar3 {
      name = "errm-cmark-gfm";
      version = "0.1.0-debug";

      src = ./.;

      nativeBuildInputs = with pkgs; [
        pkg-config just
      ];

      buildInputs = with pkgs; [
        cmark-gfm
      ];

      preBuild = ''
        sed -i 's|#!/usr/bin/env bash|#!${pkgs.bash}/bin/bash|' justfile
      '';

      env = {
        REBAR_PROFILE = "debug";
        ERL_ROOT = "${beamPackages.erlang}/lib/erlang/";
        dontUseJustBuild = "1";
        dontUseJustInstall = "1";
        dontUseJustCheck = "1";
      };
    };
  in {
    packages.${system} = {
      errm-cmark-gfm-prod = errm-prod;
      default = errm-prod;
      errm-cmark-gfm-debug = errm-debug;
    };

    devShells.${system} = {
      default = pkgs.mkShell {
        name = "errm-cmark-gfm";

        buildInputs = [
          beamPackages.erlang
          beamPackages.rebar3
          pkgs.pkg-config
          pkgs.cmark-gfm
        ];

        packages = with pkgs; [
          erlang-language-platform
          just
          clang-tools
          bear
        ];

        shellHook = ''
          export ERL_ROOT="${beamPackages.erlang}/lib/erlang"
        '';
      };
    };
  };
}
