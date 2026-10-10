{ config, lib, pkgs, ... }:
let
  graphical = config.fndx.graphical;
  cfg = graphical.bootSplash;
  desktopEnabled = graphical.enable || config.fndx.packages.i3.enable || config.fndx.packages.hyprland.enable;
  theme = pkgs.callPackage ./boot-theme { };
  chime = pkgs.writeShellApplication {
    name = "ctos-startup-chime";
    runtimeInputs = [ pkgs.alsa-utils pkgs.coreutils pkgs.gawk pkgs.systemd ];
    text = builtins.readFile ./boot-theme/play-chime.sh;
  };
in
{
  options.fndx.graphical.bootSplash = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show a black Plymouth boot screen with a white Apple-style logo and progress bar on graphical machines.";
    };
    sound = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Play an original startup chime once per boot, when the system audio device becomes available.";
      };
      device = lib.mkOption {
        type = lib.types.str;
        default = "auto";
        example = "plughw:CARD=Generic_1,DEV=0";
        description = "ALSA playback device. auto waits for a non-HDMI playback device; select HDMI explicitly if wanted. plughw bypasses user audio servers before login.";
      };
      file = lib.mkOption {
        type = lib.types.path;
        default = "${theme}/share/sounds/ctos-startup.wav";
        description = "WAV file for the boot chime. The default is synthesized locally during the build.";
      };
    };
  };

  config = lib.mkIf (desktopEnabled && cfg.enable) (lib.mkMerge [ {
    boot.plymouth = {
      enable = true;
      theme = lib.mkDefault "ctos-macos";
      themePackages = [ theme ];
    };
    boot.kernelParams = [ "quiet" ];
    boot.consoleLogLevel = lib.mkDefault 3;
    boot.initrd.verbose = lib.mkDefault false;
  } (lib.mkIf cfg.sound.enable {
    hardware.alsa.enablePersistence = lib.mkDefault true;
    systemd.services.ctos-startup-chime = {
      description = "Play the ctOS startup chime once per boot";
      wantedBy = [ "graphical.target" ];
      wants = [ "sound.target" ] ++ lib.optional config.hardware.alsa.enablePersistence "alsa-store.service";
      after = [ "sound.target" ] ++ lib.optional config.hardware.alsa.enablePersistence "alsa-store.service";
      before = [ "display-manager.service" ];
      restartIfChanged = false;
      stopIfChanged = false;
      # sound.target can be reached before any sound card has finished probing.
      # The player waits for its device instead of skipping the unit outright.
      unitConfig.ConditionPathExists = [ "!/run/ctos-startup-chime/played" ];
      environment = {
        STARTUP_SOUND_DEVICE = cfg.sound.device;
        STARTUP_SOUND_FILE = toString cfg.sound.file;
      };
      serviceConfig = {
        # Type=exec only orders launching the player before the greeter. SDDM
        # does not wait for playback to finish, and audio failure is harmless.
        Type = "exec";
        ExecStart = lib.getExe chime;
        RuntimeMaxSec = "15s";
        RuntimeDirectory = "ctos-startup-chime";
        RuntimeDirectoryMode = "0700";
        RuntimeDirectoryPreserve = "yes";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  }) ]);
}
