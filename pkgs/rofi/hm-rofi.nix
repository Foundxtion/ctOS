{osConfig, lib, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.rofi;
    defaultTerminal = "${pkgs.alacritty}/bin/alacritty";
in
with lib;
{
    xdg.configFile."rofi/spotlight-dark.rasi".source = ./spotlight-dark.rasi;
    programs.rofi = mkIf cfg.enable {
        enable = true;
        terminal = defaultTerminal;
        theme = "onedark";
    };
}
