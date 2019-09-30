let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  version = "1.0.6";
  rust = nixpkgs.latest.rustChannels.stable.rust.override {
      extensions = [
        "rust-src"
        "rls-preview"
        "clippy-preview"
        "rustfmt-preview"
      ];
    };
in

with nixpkgs;

stdenv.mkDerivation {
  name = "chromecastise-${version}";
  src = ./.;

  cargoSha256 = "1dmybqbbica7k9z9f25yzak3ji4np5mhl9xly35gjypdd2jzcf2j";

  buildInputs = [
    gitAndTools.gitflow
    rust
  ];
}
