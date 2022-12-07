{
  description = "mbf-gtf devshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
    #nixpkgs.url = "github:NixOS/nixpkgs?rev=5c09870c0244bbcf47a84f379e05bf10c7aa3f0d";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix = {
      url =
        "github:DavHau/mach-nix?rev=7e84a4e8fe088449abfa22476ad35c6cf493cad1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pypi-deps-db.follows = "pypi-deps-db";

    };
    pypi-deps-db = {
      url =
        "github:DavHau/pypi-deps-db?rev=99323880924a90acd689a4f23b56551d06d3f780";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mach-nix.follows = "mach-nix";

    };

  };

  outputs =
    { self, nixpkgs, rust-overlay, flake-utils, mach-nix, pypi-deps-db, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        mach-nix_ = (import mach-nix) {
          inherit pkgs;
          pypiDataRev = pypi-deps-db.rev;
          pypiDataSha256 = pypi-deps-db.narHash;
          python = "python38";
        };
        python_requirements = ''
              # pip
              # numpy
              # pandas
              # pybigwig
              # jupyter
              solidpython_ff
              jupyter
	      pandas
	      numpy
	      pybigwig
              dppd_plotnine
	      openpyxl
	      requests
	      requests[socks]
	      pip
	      marburg_biobank
	      bleach==4.1.0
              scipy
	      pypipegraph2
	    setuptools
          #polars
          cython-package-example
          pytest
          pytest-cov
          pytest-mock
          dppd_plotnine
          cython
          pypipegraph
          vosk
          pynput
          pint
          twine
          fritzconnection
        '';
        mypython = mach-nix_.mkPython ({
          requirements = python_requirements;
          # no r packages here - we fix the rpy2 path below.
          providers = {
            #argon2-cffi = "nixpkgs"; 
            #argon2-cffi-bindings = "nixpkgs"; 
            polars = "sdist";
            librosa = "nixpkgs";
          };
          _."jupyter-core".postInstall = ''
            rm $out/lib/python*/site-packages/jupyter.py
            rm $out/lib/python*/site-packages/__pycache__/jupyter.cpython*.pyc
          '';

        });

      in with pkgs; {
        devShell = mkShell {
          buildInputs = [
            rust-bin.stable."1.59.0".default
            #(pkgs.python39.withPackages (pp: [ pp.maturin ]))
            pkgs.maturin
            bacon
            #pkgs.python36
            # pkgs.python3
            # pkgs.python3.pkgs.pip
            # pkgs.python3.pkgs.numpy
            # pkgs.python3.pkgs.pandas
            # pkgs.python3.pkgs.pybigwig
            # pkgs.python3.pkgs.jupyter
            poppler_utils
            mypython
            julia_17-bin
          ];

          shellHook = ''
            # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
            # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
            export PIP_PREFIX=$(pwd)/_build/pip_packages
            export PYTHONPATH="$PIP_PREFIX/${mypython.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            unset SOURCE_DATE_EPOCH
          '';

        };

      });
}
