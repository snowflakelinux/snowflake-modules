{ lib, config, options, pkgs, ... }:
{
  imports = [
    ./version.nix
    ./systemd-boot.nix
    ./grub.nix
    ./gnome.nix
  ];
}
