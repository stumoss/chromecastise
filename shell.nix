with import <nixpkgs> {};

rustPlatform.buildRustPackage rec {
  name = "chromecastise-${version}";
  version = "1.0.3";
  buildInputs = [ mediainfo ffmpeg gitAndTools.gitflow ];
  src = ./.;
  cargoSha256 = "1dmybqbbica7k9z9f25yzak3ji4np5mhl9xly35gjypdd2jzcf2j";
}
