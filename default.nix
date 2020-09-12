{ nixpkgs ? <nixpkgs>, configuration ? <darwin-config>, system ? builtins.currentSystem
, pkgs ? import nixpkgs { inherit system; }
, inputs ? {}
}:

let
  evalConfig = import ./eval-config.nix { inherit (pkgs) lib; };

  eval = evalConfig {
    inherit configuration;
    inputs = { inherit nixpkgs; } // inputs;
  };

  # The source code of this repo needed by the [un]installers.
  nix-darwin = pkgs.lib.cleanSource (
    pkgs.lib.cleanSourceWith {
      # We explicitly specify a name here otherwise `cleanSource` will use the
      # basename of ./.  which might be different for different clones of this
      # repo leading to non-reproducible outputs.
      name = "nix-darwin";
      src = ./.;
    }
  );
in

{
  inherit (eval) system pkgs options config;
  installer = pkgs.callPackage ./pkgs/darwin-installer { inherit nix-darwin; };
  uninstaller = pkgs.callPackage ./pkgs/darwin-uninstaller { inherit nix-darwin; };
}
