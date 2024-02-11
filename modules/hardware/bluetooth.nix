{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.bluetooth.enable = mkEnableOption "Bluetooth for Foundxtion";

    config = mkIf config.fndx.hardware.bluetooth.enable {
        hardware.bluetooth = {
            enable = true; 
            package = pkgs.bluez;
            settings.General = {
                Enable = "Source,Sink,Media,Socket";
            };
        };

        services.blueman.enable = true;

        environment.systemPackages = with pkgs; [
            blueberry
        ];
    };
}
