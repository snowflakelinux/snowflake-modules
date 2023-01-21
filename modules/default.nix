{ lib, config, options, pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./graphical.nix
    ./hardware.nix
    ./version.nix
  ];
  nix.settings.substituters = [ "https://snowflakeos.cachix.org/" ];
  nix.settings.trusted-public-keys = [
    "snowflakeos.cachix.org-1:gXb32BL86r9bw1kBiw9AJuIkqN49xBvPd1ZW8YlqO70="
  ];
}
