{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.pulseaudio.enable = mkEnableOption "Pulseaudio for Foundxtion";

    config = mkIf config.fndx.hardware.pulseaudio.enable {
        hardware.pulseaudio.enable = true;

        environment.systemPackages = with pkgs; [
            pavucontrol
        ];
    };
}
