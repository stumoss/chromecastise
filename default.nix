{ rustPlatform, fetchFromGitHub, openssl, ffmpeg-full, stdenv, makeWrapper, mediainfo }:

with rustPlatform;

buildRustPackage rec {
  name = "chromecastise-${version}";
  version = "1.0.6";

  src = ./.; 

  cargoSha256 = "0lr8gn0fh4hag3ynkcjdkzckr5vyxk8c19wnn5xaz2dhpl44bd68";

  nativeBuildInputs = [
    openssl
    makeWrapper
  ];

  buildInputs = [
    ffmpeg-full
    mediainfo
  ];

  postInstall = ''
        wrapProgram $out/bin/chromecastise --prefix PATH : ${stdenv.lib.strings.makeBinPath [ mediainfo ffmpeg-full ]}
  '';

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
