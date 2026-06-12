{lib, osConfig, pkgs, ...}:
let
    cfg = osConfig.fndx.packages.gtk;
    Settings = {
      "gtk-application-prefer-dark-theme" = 1;
	  "gtk-cursor-theme-name" = "macOS";
  };
in
with lib;
{ 
    dconf = mkIf cfg.enable {
        enable = true;
        settings = {
            "org/gnome/desktop/wm/preferences" = {
                button-layout = "close,minimize,maximize:appmenu";
            };

            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                icon-theme = "WhiteSur-dark";
                gtk-theme = "WhiteSur-Dark";
            };
        };
    };

    gtk = mkIf cfg.enable {
        enable = true;

        iconTheme = {
            name = "WhiteSur-dark";
            package = pkgs.whitesur-icon-theme;
        };
        theme = {
            name = "WhiteSur-Dark";
            package = pkgs.whitesur-gtk-theme;
        };
		cursorTheme = {
			name = "macOS";
			package = pkgs.apple-cursor;
		};

        gtk3.extraConfig = mkIf cfg.enable Settings;

		gtk4.extraConfig = mkIf cfg.enable Settings;
    };

    home.packages = mkIf cfg.enable (with pkgs; [
        whitesur-gtk-theme
        whitesur-icon-theme
		apple-cursor
    ]);
}
