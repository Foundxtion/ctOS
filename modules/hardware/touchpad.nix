{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.touchpad.enable = mkEnableOption "Touchpad for ctOS";

    config = mkIf config.fndx.hardware.touchpad.enable {
        services.libinput = {
            enable = true;
            touchpad = {
                naturalScrolling = true;
                middleEmulation = true;
                tapping = true;
            };

            mouse = {
                accelProfile = "flat";
                accelSpeed = "0.0";
            };
        };
    };
}
