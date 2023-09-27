{lib, osConfig, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.gnome;
    unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};
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
}
