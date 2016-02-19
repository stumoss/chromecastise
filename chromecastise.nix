with import <nixpkgs> {};

let
  version = "1.0.0";
in
rustPlatform.buildRustPackage {
  name = "chromecastise-${version}";
  buildInputs = [ ];
  src = ./.;
  depsSha256 = "14n7w4a52licg8yjgirsifjjdx1v8rzwigi9jga93kwmn3hlwa6d";
}
