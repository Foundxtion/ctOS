{lib, osConfig, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.gnome;
in
with lib;
{
    dconf.settings = mkIf cfg.enable {
        "org/gnome/desktop/background" = {
            "picture-uri" = "${../../wallpapers/fire.jpg}";
        };
        "org/gnome/desktop/screensaver" = {
            "picture-uri" = "${../../wallpapers/fire.jpg}";
        };
    }; 
}
