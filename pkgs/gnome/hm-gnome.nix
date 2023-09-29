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
                "picture-uri" = "${osConfig.fndx.graphical.background}";
                "picture-uri-dark" = "${osConfig.fndx.graphical.background}";
            };
            "org/gnome/desktop/screensaver" = {
                "picture-uri" = "${osConfig.fndx.graphical.background}";
                "picture-uri-dark" = "${osConfig.fndx.graphical.background}";
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

    home.sessionVariables.GTK_THEME = mkIf cfg.enable "WhiteSur-Theme";

    home.packages = mkIf cfg.enable (with pkgs; [
        gnomeExtensions.big-sur-status-area
        whitesur-gtk-theme
        whitesur-icon-theme
    ]);
}
