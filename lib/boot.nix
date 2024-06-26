{pkgs, config, ...}:
{
  boot = {
    loader = {
        systemd-boot.enable = true;
        efi = {
            canTouchEfiVariables = true;
        };
    };
    kernelPackages = pkgs.linuxPackages_6_6;
  };
}
