{config, lib, pkgs, ...}:
with lib;
{
    options.fndx.hardware.pulseaudio.enable = mkEnableOption "Pulseaudio for ctOS";

    config = mkIf config.fndx.hardware.pulseaudio.enable {
        hardware.pulseaudio = {
            enable = true;
            package = pkgs.pulseaudioFull;
        };

        environment.systemPackages = with pkgs; [
            pavucontrol
        ];
    };
}
