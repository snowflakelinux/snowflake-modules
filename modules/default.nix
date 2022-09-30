{ lib, config, options, pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./graphical.nix
    ./grub.nix
    ./systemd-boot.nix
    ./version.nix
  ];
}
