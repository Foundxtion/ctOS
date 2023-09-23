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

            font.normal.family = "MesloLGS NF";
            font.normal.size = 36;

            window.opacity = 0.7;
        };
    };
}
