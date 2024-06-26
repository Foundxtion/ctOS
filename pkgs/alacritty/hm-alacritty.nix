{osConfig, lib, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.alacritty;
in
with lib;
{
    programs.alacritty = mkIf cfg.enable {
        enable = true;
        settings = {
            colors = {
                primary = {
                    background = "#242424";
                    foreground = "#ffffff";
                };
            };

            font.normal.family = "DejaVuSansM Nerd Font";
            # font.normal.size = 36;

            window = {
                opacity = 0.7;
                dimensions = {
                    columns = 80;
                    lines = 30;
                };
            };
        };
    };
}
