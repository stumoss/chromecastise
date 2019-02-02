{ stdenv, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "chromecastise-${version}";
  version = "1.0.3";

  src = ./.;

  cargoSha256 = "1dmybqbbica7k9z9f25yzak3ji4np5mhl9xly35gjypdd2jzcf2j";

  meta = with stdenv.lib; {
    description = "Wrapper for ffmpeg to convert your media for use with chromecast";
    homepage = https://github.com/stumoss/chromecastise;
    license = licenses.MIT;
    maintainers = [ maintainers.stumoss ];
    platforms = platforms.all;
  };
}
