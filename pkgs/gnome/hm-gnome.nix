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
            name = "Whitesur";
            package = unstable.whitesur-icon-theme;
        };

        theme = {
            name = "Whitesur";
            package = unstable.whitesur-gtk-theme;
        };

        cursorTheme = {
            name = "Whitesur";
            package = unstable.whitesur-cursors;
        };
    };

    gtk3.extraConfig = mkIf cfg.enable {
       inherit Settings;
    };
    gtk4.extraConfig = mkIf cfg.enable {
       inherit Settings;
    };

    home.sessionVariables.GTK_THEME = "Whitesur";
}
