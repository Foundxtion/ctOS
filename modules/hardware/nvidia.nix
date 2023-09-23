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

        hardware.nvidia = {
            modesetting.enable = true;
            open = false;

            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        environment.variables = {
            CUDA_PATH = "${pkgs.cudatoolkit}";      
        };
    };
}
