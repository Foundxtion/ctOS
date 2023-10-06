{lib, osConfig, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.gnome;
    Settings = ''
      gtk-application-prefer-dark-theme=1
    '';
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

                enabled-extensions = [
                    "user-themes@gnome-shell-extensions.gcampax.github.com"
                ];
            };
            "org/gnome/shell/extensions/user-theme" = {
                name = "WhiteSur-Dark";
            };
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
            };
        };
    }; 
    
    gtk = mkIf cfg.enable {
        enable = true;

        iconTheme = {
            name = "WhiteSur-Icon";
            package = pkgs.whitesur-icon-theme;
        };
        theme = {
            name = "WhiteSur-Theme";
            package = pkgs.whitesur-gtk-theme;
        };
    };

    home.sessionVariables = mkIf cfg.enable {
        GTK_THEME = "WhiteSur-Dark";
    };

    home.packages = mkIf cfg.enable (with pkgs; [
        gnomeExtensions.big-sur-status-area
        whitesur-gtk-theme
        whitesur-icon-theme
    ]);
}
