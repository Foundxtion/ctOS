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
            enable  = true;
            fade    = true;
            backend = "glx";
            shadow  = true;

            opacityRules = [
                "85:class_g = 'Code'"
                "85:class_g = 'discord'"
                "85:class_g = 'Rofi'"
                "100:class_g = 'Polybar'"
            ];

            fadeSteps = [0.08 0.08];

            settings = {
                blur = {
                    method           = "dual_kawase";
                    strength         = 12;
                    background       = false;
                    background-frame = false;
                    background-fixed = false;
                };

                blur-background-exclude = [
                    "window_type = 'utility'"
                ];

                corner-radius = 10;
                use-damage    = false;

                rounded-corners-exclude = [
                    "window_type = 'dock'"
                ];

                shadow-exclude = [
                    "class_g = 'Polybar'"
                    "window_type = 'utility'"
                ];
            };
        };
    };
}
