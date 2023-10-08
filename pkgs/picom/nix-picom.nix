{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.picom;
in
with lib;
{
    options = {
        fndx.packages.picom.enable = mkEnableOption "Picom for Foundxtion";
    };

    config = mkIf cfg.enable {
        services.picom = {
            enable = true;
            fade = true;
            backend = "glx";
            opacityRules = [
                "85:class_g = 'Code'"
                "85:class_g = 'discord'"
            ];

            fadeSteps = [0.08 0.08];

            settings = {
                blur = {
                    method = "dual_kawase";
                    strength = 12;
                    background = false;
                    background-frame = false;
                    background-fixed = false;
                };
                corner-radius = 10;
            };
        };
    };
}
