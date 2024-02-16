{lib, osConfig, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.gnome;
in
with lib;
{ 
    dconf = mkIf cfg.enable {
        enable = true;
        settings = {
            "org/gnome/desktop/background" = {
                "picture-uri" = "${osConfig.fndx.graphical.background}";
                "picture-uri-dark" = "${osConfig.fndx.graphical.background}";
            };
            "org/gnome/desktop/screensaver" = {
                "picture-uri" = "${osConfig.fndx.graphical.background}";
                "picture-uri-dark" = "${osConfig.fndx.graphical.background}";
            };

            "org/gnome/shell" = {
                disable-user-extensions = false;

                disabled-extensions = [];

                enabled-extensions = [
                    "user-themes@gnome-shell-extensions.gcampax.github.com"
                    "user-theme@gnome-shell-extensions.gcampax.github.com"
                ];
            };

            "org/gnome/shell/extensions/user-theme" = {
                name = "WhiteSur-Dark";
            };

            "org/gnome/desktop/wm/preferences" = {
                button-layout = "close,minimize,maximize:appmenu";
            };

            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                cursor-theme = "Adwaita";
                icon-theme = "WhiteSur-dark";
                gtk-theme = "WhiteSur-Dark";
            };
        };
    }; 

    home.packages = mkIf cfg.enable (with pkgs; [
        gnomeExtensions.big-sur-status-area
    ]);
}
