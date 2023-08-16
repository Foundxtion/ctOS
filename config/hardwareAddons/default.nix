{ config, pkgs, ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
