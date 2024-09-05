{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        lisp = pkgs.sbcl;
        lispPackages = pkgs.sbclPackages;
        pname = "lisp-cli";
        version = "0.1.0";
        src = lib.cleanSource ./.;
        lispLibs = with lispPackages; [
          clingon
        ];

        lisp-cli = lisp.buildASDFSystem {
          inherit pname version src lispLibs;
        };
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        packages = {
          inherit lisp-cli;
          default = lisp-cli;
        };

        checks = {
          inherit lisp-cli;
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            # SBCL
            lisp

            # LSP
            pkgs.nil
          ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };
      });
}
