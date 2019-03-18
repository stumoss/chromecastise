{ stdenv, rustPlatform, ffmpeg, mediainfo }:

rustPlatform.buildRustPackage rec {
  name = "chromecastise-${version}";
  version = "1.0.3";

  src = ./.;

  cargoSha256 = "1dmybqbbica7k9z9f25yzak3ji4np5mhl9xly35gjypdd2jzcf2j";

  buildInputs = [
    ffmpeg
    mediainfo
    ];

   preFixup = ''
    mkdir -p "$out/share/"{bash-completion/completions,fish/vendor_completions.d,zsh/site-functions}
    cp target/release/build/chromecastise-*/out/chromecastise.bash "$out/share/bash-completion/completions/"
    cp target/release/build/chromecastise-*/out/chromecastise.fish "$out/share/fish/vendor_completions.d/"
    cp target/release/build/chromecastise-*/out/_chromecastise "$out/share/zsh/site-functions/"
  '';

  meta = with stdenv.lib; {
    description = "Wrapper for ffmpeg to convert your media for use with chromecast";
    homepage = https://github.com/stumoss/chromecastise;
    license = licenses.MIT;
    maintainers = [ maintainers.stumoss ];
    platforms = platforms.all;
  };
}
