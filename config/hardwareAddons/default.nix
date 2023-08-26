{ config, pkgs, ... }:
{
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
  
      nvidiaSettings = true;
  
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
}
