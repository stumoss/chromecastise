{
  description = "A simple transcoding tool to make videos compatible with chromecast devices";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.09;
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
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
              wrapProgram $out/bin/chromecastise --prefix PATH : ${pkgs.stdenv.lib.strings.makeBinPath [ pkgs.mediainfo pkgs.ffmpeg-full ]}
            '';
          };
        };

        defaultPackage = packages.chromecastise;
        apps.chromecastise = flake-utils.lib.mkApp { drv = packages.chromecastise; };
        defaultApp = apps.chromecastise;
      }
    );
}
