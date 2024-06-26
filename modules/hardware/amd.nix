{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.hardware.amd.enable = mkEnableOption "AMD GPU support";
    };

    config = mkIf config.fndx.hardware.amd.enable {
       boot.kernelModules = ["amdgpu"]; 
       services.xserver.videoDrivers = [ "modesetting" ];

       hardware.opengl = {
           extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
           extraPackages = with pkgs; [ amdvlk ];
       };

       environment.systemPackages = with pkgs; [
           nvtopPackages.amd
       ];
    };
}
