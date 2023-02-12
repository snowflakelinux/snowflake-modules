{ lib, config, options, pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./graphical.nix
    ./hardware.nix
    ./version.nix
  ];

  # Reasonable Defaults
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://snowflakeos.cachix.org/" ];
    trusted-public-keys = [
      "snowflakeos.cachix.org-1:gXb32BL86r9bw1kBiw9AJuIkqN49xBvPd1ZW8YlqO70="
    ];
  } // (lib.mapAttrsRecursive (_: lib.mkDefault) {
    connect-timeout = 5;
    log-lines = 25;
    min-free = 128000000;
    max-free = 1000000000;
    fallback = true;
    warn-dirty = false;
    auto-optimise-store = true;
    linkInputs = true;
    generateNixPathFromInputs = true;
    generateRegistryFromInputs = true;
  });
}
