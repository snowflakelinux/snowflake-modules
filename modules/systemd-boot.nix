{ lib, config, options, pkgs, ... }:
let
  cfg = config.boot.loader.systemd-boot;
  efi = config.boot.loader.efi;
  systemdBootBuilder = pkgs.substituteAll {
    src = /${pkgs.path}/nixos/modules/system/boot/loader/systemd-boot/systemd-boot-builder.py;

    isExecutable = true;

    inherit (pkgs) python3;

    systemd = config.systemd.package;

    nix = config.nix.package.out;

    timeout = if config.boot.loader.timeout != null then config.boot.loader.timeout else "";

    editor = if cfg.editor then "True" else "False";

    configurationLimit = if cfg.configurationLimit == null then 0 else cfg.configurationLimit;

    inherit (cfg) consoleMode graceful;

    inherit (efi) efiSysMountPoint canTouchEfiVariables;

    memtest86 = if cfg.memtest86.enable then pkgs.memtest86-efi else "";

    netbootxyz = if cfg.netbootxyz.enable then pkgs.netbootxyz-efi else "";

    copyExtraFiles = pkgs.writeShellScript "copy-extra-files" ''
      empty_file=$(${pkgs.coreutils}/bin/mktemp)
      ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
        ${pkgs.coreutils}/bin/install -Dp "${v}" "${efi.efiSysMountPoint}/"${lib.escapeShellArg n}
        ${pkgs.coreutils}/bin/install -D $empty_file "${efi.efiSysMountPoint}/efi/nixos/.extra-files/"${lib.escapeShellArg n}
      '') cfg.extraFiles)}
      ${lib.concatStrings (lib.mapAttrsToList (n: v: ''
        ${pkgs.coreutils}/bin/install -Dp "${pkgs.writeText n v}" "${efi.efiSysMountPoint}/loader/entries/"${lib.escapeShellArg n}
        ${pkgs.coreutils}/bin/install -D $empty_file "${efi.efiSysMountPoint}/efi/nixos/.extra-files/loader/entries/"${lib.escapeShellArg n}
      '') cfg.extraEntries)}
    '';
  };

  checkedSystemdBootBuilder = pkgs.runCommand "systemd-boot" {
    nativeBuildInputs = [ pkgs.mypy pkgs.python3 ];
  } ''
    install -m755 ${systemdBootBuilder} $out
    substituteInPlace $out \
      --replace "NixOS" "SnowflakeOS"
    mypy \
      --no-implicit-optional \
      --disallow-untyped-calls \
      --disallow-untyped-defs \
      $out
  '';

  finalSystemdBootBuilder = pkgs.writeScript "install-systemd-boot.sh" ''
    #!${pkgs.runtimeShell}
    ${checkedSystemdBootBuilder} "$@"
    ${cfg.extraInstallCommands}
  '';

in

{
  config = lib.mkIf (config.boot.loader.systemd-boot.enable && config.snowflakeos.osInfo.enable)
    {
      system = {
        build.installBootLoader = lib.mkForce finalSystemdBootBuilder;

        boot.loader.id = "systemd-boot";

        requiredKernelConfig = with config.lib.kernelConfig; [
          (isYes "EFI_STUB")
        ];
      };
    };
}
