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
                "picture-uri" = "${../../wallpapers/fire.jpg}";
                "picture-uri-dark" = "${../../wallpapers/fire.jpg}";
            };
            "org/gnome/desktop/screensaver" = {
                "picture-uri" = "${../../wallpapers/fire.jpg}";
                "picture-uri-dark" = "${../../wallpapers/fire.jpg}";
            };
        };
    }; 
}
