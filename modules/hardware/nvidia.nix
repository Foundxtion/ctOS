{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.hardware.nvidia.enable = mkEnableOption "Nvidia GPU support";
    };

    config = mkIf config.fndx.hardware.nvidia.enable {
        hardware.opengl = {
            enable = true;
            driSupport = true;
            driSupport32Bit = true;
        };

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
            modesetting.enable = true;
            open = false;

            nvidiaPersistenced =  true;

            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.production;
        };

       boot.kernelModules = [ "nvidia_uvm" ];

        environment.systemPackages = with pkgs; [
            nvtopPackages.nvidia
        ];
    };
}
