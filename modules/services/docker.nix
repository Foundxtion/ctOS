{config, pkgs, lib, ...}:
with lib;
{
  options = {
      fndx.services.docker.enable = mkEnableOption "Docker";
  };

  config = mkIf config.fndx.services.docker.enable {
      virtualisation.docker.enable = true; 
      virtualisation.docker.enableNvidia = config.fndx.hardware.nvidia.enable;
  };
}
