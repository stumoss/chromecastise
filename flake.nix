{
  description = "A simple transcoding tool to make videos compatible with chromecast devices";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          rec {
            packages = flake-utils.lib.flattenTree {
              chromecastise = pkgs.rustPlatform.buildRustPackage {
                name = "chromecastise";

                src = self;

                cargoSha256 = "fv7CgjAZwgHXlC72x0/+9SVh2THd/kYzf1z1Pa8a1yU=";

                buildInputs = [
                  pkgs.openssl
                  pkgs.makeWrapper
                  pkgs.installShellFiles
                ];

                postInstall = ''
                  wrapProgram $out/bin/chromecastise --prefix PATH : ${pkgs.lib.strings.makeBinPath [ pkgs.mediainfo pkgs.ffmpeg-full ]}
                '';
              };
            };

            defaultPackage = packages.chromecastise;
            apps.chromecastise = flake-utils.lib.mkApp { drv = packages.chromecastise; };
            defaultApp = apps.chromecastise;
            overlay = final: prev:
              {
                chromecastise = defaultPackage.${system}.chromecastise;
              };
          }
    );


}
