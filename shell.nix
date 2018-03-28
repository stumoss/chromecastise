with import <nixpkgs> {};

let
  version = "1.0.3";
in
rustPlatform.buildRustPackage {
  name = "chromecastise-${version}";
  buildInputs = [ rustfmt ];
  src = ./.;
  cargoSha256 = "1dmybqbbica7k9z9f25yzak3ji4np5mhl9xly35gjypdd2jzcf2j";
}
