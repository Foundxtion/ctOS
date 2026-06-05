{pkgs, config, ...}:
{
  boot = {
    loader = {
        systemd-boot.enable = true;
        efi = {
            canTouchEfiVariables = true;
        };
    };
    kernelPackages = if (config.fndx.hardware.vbox.enable || config.fndx.hardware.nvidia.enable) then pkgs.linuxPackages_6_12 else pkgs.linuxPackages_latest;
  };
}
