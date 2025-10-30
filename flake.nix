{
  description = "A simple transcoding tool to make videos compatible with chromecast devices";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:
        rec {
          chromecastise = pkgs.rustPlatform.buildRustPackage {
            name = "chromecastise";
            src = self;
            cargoHash = "sha256-BTp5du2m7sSlbvIrpI+YEmGURp2YteiojS2raBnNoKg=";

            buildInputs = [
              pkgs.openssl
              pkgs.makeWrapper
              pkgs.installShellFiles
            ];

            postInstall = ''
              wrapProgram $out/bin/chromecastise --prefix PATH : ${
                pkgs.lib.strings.makeBinPath [
                  pkgs.mediainfo
                  pkgs.ffmpeg
                ]
              }
            '';
          };
          default = chromecastise;
        }
      );

      overlays.default = final: prev: {
        inherit (self.packages.${prev.system}) chromecastise;
      };
    };
}
