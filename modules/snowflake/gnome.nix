{ lib, config, options, pkgs, ... }:
let
  nixos-background-info = pkgs.stdenv.mkDerivation { name = "nixos-background-info"; };
  snowflakeos-background-info = pkgs.writeTextFile rec {
    name = "snowflakeos-background-info";
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
      <wallpapers>
        <wallpaper deleted="false">
          <name>Blobs</name>
          <filename>${pkgs.nixos-artwork.wallpapers.nineish.gnomeFilePath}</filename>
          <filename-dark>${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}</filename-dark>
          <options>zoom</options>
          <shade_type>solid</shade_type>
          <pcolor>#3a4ba0</pcolor>
          <scolor>#2f302f</scolor>
        </wallpaper>
      </wallpapers>
    '';
    destination = "/share/gnome-background-properties/snowflakeos.xml";
  };
in
{
  options.snowflakeos.gnome = {
    enable = lib.mkEnableOption "SnowflakeOS GNOME configuration";
  };

  config = lib.mkIf config.snowflakeos.gnome.enable {
    snowflakeos.graphical.enable = true;
    services.xserver.displayManager.gdm.enable = lib.mkDefault true;
    services.xserver.desktopManager.gnome = {
      enable = lib.mkDefault true;
      favoriteAppsOverride = lib.mkDefault ''
        [org.gnome.shell]
        favorite-apps=[ 'firefox.desktop', 'org.gnome.Geary.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Nautilus.desktop', 'dev.vlinkz.NixSoftwareCenter.desktop' ]
      '';
      extraGSettingsOverrides = ''
        [org.gnome.desktop.background]
        picture-uri='file://${pkgs.nixos-artwork.wallpapers.nineish.gnomeFilePath}'
        picture-uri-dark='file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}'
        [org.gnome.desktop.screensaver]
        picture-uri='file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}'
      '';
    };
    environment.gnome.excludePackages = [ nixos-background-info ];
    environment.systemPackages = [ snowflakeos-background-info ];
  };
}
