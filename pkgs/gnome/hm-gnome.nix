{lib, osConfig, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.gnome;
    unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
    Settings = ''
      gtk-application-prefer-dark-theme=1
    '';
in
with lib;
{ 
    dconf = mkIf cfg.enable {
        enable = true;
        settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                enable-hot-corners = false;
            };
            "org/gnome/desktop/background" = {
                "picture-uri" = "${../../wallpapers/fire.jpg}";
                "picture-uri-dark" = "${../../wallpapers/fire.jpg}";
            };
            "org/gnome/desktop/screensaver" = {
                "picture-uri" = "${../../wallpapers/fire.jpg}";
                "picture-uri-dark" = "${../../wallpapers/fire.jpg}";
            };
        };
    }; 

    gtk = mkIf cfg.enable {
        enable = true;

        iconTheme = {
            name = "Whitesur-icon";
            package = unstable.whitesur-icon-theme;
        };

        theme = {
            name = "Whitesur-theme";
            package = unstable.whitesur-gtk-theme;
        };

        cursorTheme = {
            name = "Whitesur-cursor";
            package = unstable.whitesur-cursors;
        };
        gtk3.extraConfig = mkIf cfg.enable {
           inherit Settings;
        };
        gtk4.extraConfig = mkIf cfg.enable {
           inherit Settings;
        };
    };


    home.sessionVariables.GTK_THEME = "Whitesur-theme";
    home.packages = mkIf cfg.enable [
        unstable.whitesur-gtk-theme
        unstable.whitesur-cursors
        unstable.whitesur-icon-theme
    ];
}
