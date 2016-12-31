with import <nixpkgs> {};

let
  version = "1.0.1";
in
rustPlatform.buildRustPackage {
  name = "chromecastise-${version}";
  buildInputs = [ ];
  src = ./.;
  depsSha256 = "0r91zd41mn079kzmjx2nns8zysc4y2ymyws349k46miz3xbnr8wh";
}
