with import <nixpkgs> {};

let
  version = "1.0.2";
in
rustPlatform.buildRustPackage {
  name = "chromecastise-${version}";
  buildInputs = [ rustfmt ];
  src = ./.;
  cargoSha256 = "1a2l7ryiwkzqqapssznk8d96h4pk2fm96x2wgz582jb1ylp3l9jl";
}
