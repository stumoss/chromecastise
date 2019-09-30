{ stdenv, dockerTools, writeScript, callPackage }:

let
  chromecastise = callPackage ./default.nix {};
in
dockerTools.buildImage {
  name = "chromecastise";
  tag = chromecastise.version;
  config.Entrypoint = [ "${chromecastise}/bin/chromecastise" ];
  created = "now";
}
