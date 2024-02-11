{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.pulseaudio.enable = mkEnableOption "Pulseaudio for Foundxtion";

    config = mkIf config.fndx.hardware.pulseaudio.enable {
        hardware.pulseaudio.enable = true;
        hardware.pulseaudio = {
            enable = true;
            package = pkgs.pulseaudioFull;
        };

        environment.systemPackages = with pkgs; [
            pavucontrol
        ];
    };
}
