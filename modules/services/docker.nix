{config, pkgs, lib, ...}:
with lib;
{
  options = {
      fndx.services.docker.enable = mkEnableOption "Docker";
  };

  config = mkIf config.fndx.services.docker.enable {
      virtualisation.docker.enable = true; 
      virtualisation.docker.package = pkgs.docker_25;
      hardware.nvdia-container-toolkit.enable = config.fndx.hardware.nvidia.enable;
  };
}
