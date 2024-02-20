{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.hardware.amd.enable = mkEnableOption "AMD GPU support";
    };

    config = mkIf config.fndx.hardware.amd.enable {
       boot.initrd.kernelModules = ["amdgpu"]; 
       services.xserver.videoDrivers = [ "amdgpu" ];

       environment.systemPackages = with pkgs; [
           nvtop
       ];
    };
}
