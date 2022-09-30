{ lib, config, options, pkgs, ... }:
{
  options.snowflakeos.graphical = {
    enable = lib.mkEnableOption "SnowflakeOS default graphical configurations (not including DE)";
  };

  config = lib.mkIf config.snowflakeos.graphical.enable {
    # Enable fwupd
    services.fwupd.enable = lib.mkDefault true;

    # Add opengl/vulkan support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Enable NetworkManager
    networking.networkmanager.enable = lib.mkDefault true;

    # Enable sound with pipewire.
    sound.enable = lib.mkDefault true;
    hardware.pulseaudio.enable = lib.mkDefault false;
    security.rtkit.enable = lib.mkDefault true;
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };

    # Enable CUPS to print documents.
    services.printing.enable = lib.mkDefault true;
  };
}
