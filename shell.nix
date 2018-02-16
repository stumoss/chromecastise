with import <nixpkgs> {};

let
  version = "1.0.3";
in
rustPlatform.buildRustPackage {
  name = "chromecastise-${version}";
  buildInputs = [ rustfmt ];
  src = ./.;
  cargoSha256 = "1w2nz51yyvxr8h78s7gdh16svvivr71jj5bcnyv4n4wpcd789abf";
}
