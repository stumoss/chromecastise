{
  description = "A simple transcoding tool to make videos compatible with chromecast devices";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      allSupportedSystems = flake-utils.lib.eachSystem [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    allSupportedSystems
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          packages = flake-utils.lib.flattenTree rec {
            chromecastise = pkgs.rustPlatform.buildRustPackage {
              name = "chromecastise";

              src = self;

              cargoHash = "sha256-uVK62ra+G5TvpG7pCEawWYEQj4WlsrNtYCiA/GGAhTQ=";

              buildInputs = [
                pkgs.openssl
                pkgs.makeWrapper
                pkgs.installShellFiles
              ];

              postInstall = ''
                wrapProgram $out/bin/chromecastise --prefix PATH : ${pkgs.lib.strings.makeBinPath [ pkgs.mediainfo pkgs.ffmpeg ]}
              '';
            };
            default = chromecastise;
          };

          apps.chromecastise = flake-utils.lib.mkApp { drv = packages.chromecastise; };
          apps.default = apps.chromecastise;
        }
      ) //
    {
      overlays.default = final: prev: {
        inherit (self.packages.${prev.system}) chromecastise;
      };
    };
}
