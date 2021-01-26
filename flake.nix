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
            cargoSha256 = "0h09n2b0wpa2nfy07z3nw7w3x3hfjgm2n8lwk1bdwl63j6nm96sr";
            propagatedNativeBuildInputs = [
              pkgs.mediainfo
              pkgs.ffmpeg
            ];
          };
        };

        defaultPackage = packages.chromecastise;
        apps.chromecastise = flake-utils.lib.mkApp { drv = packages.chromecastise; };
        defaultApp = apps.chromecastise;
      }
    );
}
