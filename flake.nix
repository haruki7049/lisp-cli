{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        stdenv = pkgs.stdenv;
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

        lisp-cli-asdf = lisp.buildASDFSystem {
          inherit
            pname
            version
            src
            lispLibs
            ;
        };

        lisp-cli = let
          dependenciesLoading = lib.concatLines (map (x: "(asdf:load-system '${x.pname})") lispLibs ++ [ lisp-cli-asdf ]);
        in stdenv.mkDerivation {
          inherit pname version src;

          nativeBuildInputs = [
            (lisp.withPackages (ps: lispLibs ++ [ lisp-cli-asdf ]))
          ];

          #buildInputs = [
          #  (lisp.withPackages (ps: lispLibs ++ [ lisp-cli-asdf ]))
          #];

          dontStrip = true;

            #${dependenciesLoading}
          buildPhase = ''
            sbcl --script << EOF
            (load (sb-ext:posix-getenv "ASDF"))
            (asdf:load-system 'clingon)
            (asdf:load-system 'lisp-cli)


            (sb-ext:save-lisp-and-die "${pname}" :executable t :toplevel #'${pname}:main)
            EOF
          '';

          installPhase = ''
            mkdir -p $out/bin
            install -Dm744 ${pname} $out/bin
          '';
        };
      in
      {
        formatter = treefmtEval.config.build.wrapper;

        packages = {
          inherit lisp-cli-asdf lisp-cli;
        };

        checks = {
          inherit lisp-cli-asdf;
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            # SBCL
            (lisp.withPackages (ps: lispLibs))

            # LSP
            pkgs.nil
          ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };
      }
    );
}
