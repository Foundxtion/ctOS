{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.hardware.amd.enable = mkEnableOption "AMD GPU support";
    };

    config = mkIf config.fndx.hardware.amd.enable {
       boot.kernelModules = ["amdgpu"]; 
       services.xserver.videoDrivers = [ "amdgpu" ];

       hardware.graphics = {
           enable = true;
       };

       environment.systemPackages = with pkgs; [
           nvtopPackages.amd
       ];
    };
}
