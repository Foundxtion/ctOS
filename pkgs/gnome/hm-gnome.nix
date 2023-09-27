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

}
