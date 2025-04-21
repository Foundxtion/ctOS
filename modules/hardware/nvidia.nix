{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.hardware.nvidia.enable = mkEnableOption "Nvidia GPU support";
    };

    config = mkIf config.fndx.hardware.nvidia.enable {
        hardware.graphics = {
            enable = true;
        };

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
            powerManagement.enable = false;
            modesetting.enable = true;
            open = false;

            nvidiaPersistenced =  true;

            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

       # boot.kernelModules = [ "nvidia_uvm" ];

        environment.systemPackages = with pkgs; [
            nvtopPackages.nvidia
        ];
    };
}
