{ lib, config, options, pkgs, ... }:

with lib;

let
  cfg = config.boot.loader.grub;
  efi = config.boot.loader.efi;
  grubPkgs =
    # Package set of targeted architecture
    if cfg.forcei686 then pkgs.pkgsi686Linux else pkgs;

  realGrub =
    if cfg.version == 1 then grubPkgs.grub
    else if cfg.zfsSupport then grubPkgs.grub2.override { zfsSupport = true; }
    else if cfg.trustedBoot.enable
    then if cfg.trustedBoot.isHPLaptop
    then grubPkgs.trustedGrub-for-HP
    else grubPkgs.trustedGrub
    else grubPkgs.grub2;

  grub =
    # Don't include GRUB if we're only generating a GRUB menu (e.g.,
    # in EC2 instances).
    if cfg.devices == [ "nodev" ]
    then null
    else realGrub;

  grubEfi =
    # EFI version of Grub v2
    if cfg.efiSupport && (cfg.version == 2)
    then realGrub.override { efiSupport = cfg.efiSupport; }
    else null;

  f = x: if x == null then "" else "" + x;
  grubConfig = args:
    let
      efiSysMountPoint = if args.efiSysMountPoint == null then args.path else args.efiSysMountPoint;
      efiSysMountPoint' = replaceChars [ "/" ] [ "-" ] efiSysMountPoint;
    in
    pkgs.writeText "grub-config.xml" (builtins.toXML
      {
        splashImage = f cfg.splashImage;
        splashMode = f cfg.splashMode;
        backgroundColor = f cfg.backgroundColor;
        entryOptions = f cfg.entryOptions;
        subEntryOptions = f cfg.subEntryOptions;
        grub = f grub;
        grubTarget = f (grub.grubTarget or "");
        shell = "${pkgs.runtimeShell}";
        fullName = lib.getName realGrub;
        fullVersion = lib.getVersion realGrub;
        grubEfi = f grubEfi;
        grubTargetEfi = if cfg.efiSupport && (cfg.version == 2) then f (grubEfi.grubTarget or "") else "";
        bootPath = args.path;
        storePath = config.boot.loader.grub.storePath;
        bootloaderId = if args.efiBootloaderId == null then "SnowflakeOS${efiSysMountPoint'}" else args.efiBootloaderId;
        timeout = if config.boot.loader.timeout == null then -1 else config.boot.loader.timeout;
        users = if cfg.users == { } || cfg.version != 1 then cfg.users else throw "GRUB version 1 does not support user accounts.";
        theme = f cfg.theme;
        inherit efiSysMountPoint;
        inherit (args) devices;
        inherit (efi) canTouchEfiVariables;
        inherit (cfg)
          version extraConfig extraPerEntryConfig extraEntries forceInstall useOSProber
          extraGrubInstallArgs
          extraEntriesBeforeNixOS extraPrepareConfig configurationLimit copyKernels
          default fsIdentifier efiSupport efiInstallAsRemovable gfxmodeEfi gfxmodeBios gfxpayloadEfi gfxpayloadBios;
        path = with pkgs; makeBinPath (
          [ coreutils gnused gnugrep findutils diffutils btrfs-progs util-linux mdadm ]
          ++ optional (cfg.efiSupport && (cfg.version == 2)) efibootmgr
          ++ optionals cfg.useOSProber [ busybox os-prober ]
        );
        font =
          if cfg.font == null then ""
          else
            (if lib.last (lib.splitString "." cfg.font) == "pf2"
            then cfg.font
            else "${convertedFont}");
      });
  install-grub-pl = pkgs.substitute {
    src = pkgs.substituteAll {
      src = /${pkgs.path}/nixos/modules/system/boot/loader/grub/install-grub.pl;
      utillinux = pkgs.util-linux;
      btrfsprogs = pkgs.btrfs-progs;
    };
    replacements = [[ "--replace" "NixOS" "SnowflakeOS" ] [ "--replace" "extraEntriesBeforeSnowflakeOS" "extraEntriesBeforeNixOS" ]];
  };
  
  perl = pkgs.perl.withPackages (p: with p; [
    FileSlurp
    FileCopyRecursive
    XMLLibXML
    XMLSAX
    XMLSAXBase
    ListCompare
    JSON
  ]);
in
{
  config = lib.mkIf (config.boot.loader.grub.enable && config.snowflakeos.osInfo.enable)
    {
      system.build.installBootLoader =
        lib.mkForce (pkgs.writeScript "install-grub.sh" (''
          #!${pkgs.runtimeShell}
          set -e
          ${lib.optionalString cfg.enableCryptodisk "export GRUB_ENABLE_CRYPTODISK=y"}
        '' + lib.flip lib.concatMapStrings cfg.mirroredBoots (args: ''
          ${perl}/bin/perl ${install-grub-pl} ${grubConfig args} $@
        '') + cfg.extraInstallCommands));
    };
}
