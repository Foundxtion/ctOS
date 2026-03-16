{pkgs, config, ...}:
{
  boot = {
    loader = {
        systemd-boot.enable = true;
        efi = {
            canTouchEfiVariables = true;
        };
    };
    kernelPackages = if (config.hardware.vbox.enable) then pkgs.linuxPackages_6_12 else pkgs.linuxPackages_latest;
  };
}
