{config, lib, pkgs, ...}:
let
    cfg = config.fndx.graphical;
    # Chili imports QtQuick Controls 1 and QtGraphicalEffects, both Qt 5 APIs.
    # nixpkgs 26.05 no longer exposes libsForQt5.sddm, so use the upstream
    # overridable derivation with a consistent Qt 5 build and wrapper.
    chiliSddm = pkgs.kdePackages.sddm.override {
        sddm-unwrapped = pkgs.kdePackages.sddm.unwrapped.override {
            inherit (pkgs.libsForQt5) qtbase qtdeclarative qttools qtquickcontrols2;
        };
        wrapQtAppsHook = pkgs.libsForQt5.wrapQtAppsHook;
    };
in
with lib;
{
    imports = [ ./boot.nix ];

	options = {
		fndx.graphical.enable = mkEnableOption "ctOS graphic interface";
		fndx.graphical.enableTouchpad = mkEnableOption "touchpad on ctOS graphical interface";
		fndx.graphical.background = mkOption {
			default = ../../wallpapers/macos-1.jpg;

			description = mdDoc "ctOS background for graphical interface";
		};
		fndx.graphical.loginBackground = mkOption {
			default = ../../wallpapers/macos-1.jpg;

			description = mdDoc "ctOS login background for graphical interface";
		};
		fndx.graphical.hidpi = mkOption {
			default = false;
			description = mdDoc "Option to set the dpi for 4K Display and Apple's Retina Display";
			type = types.bool;
		};
		fndx.graphical.wm = mkOption {
			type = types.enum [ "i3" "hyprland" ];
			default = "i3";
			description = mdDoc "Window manager to use (i3 or hyprland)";
		};
        fndx.graphical.cursor = {
            size = mkOption {
                type = types.ints.positive;
                default = 24;
                description = "Cursor size in logical pixels, shared by SDDM and desktop sessions.";
            };
            name = mkOption {
                type = types.str;
                default = "macOS";
                description = "Cursor theme directory name.";
            };
            package = mkOption {
                type = types.package;
                default = pkgs.apple-cursor;
                description = "Package containing the cursor theme.";
            };
        };
        fndx.graphical.sddm = {
            theme = mkOption {
                type = types.str;
                default = "chili";
                description = mdDoc "Theme directory name inside the SDDM theme package.";
            };
            themePackage = mkOption {
                type = types.package;
                default = import ./sddm/chili.nix { inherit pkgs; background = cfg.loginBackground; };
                description = mdDoc "SDDM theme package. Match SDDM's Qt version to the theme's dependencies.";
            };
        };
	};

	config = mkMerge [ (mkIf cfg.enable {
		environment.systemPackages = with pkgs; [
			google-chrome
			feh
		];

        services.xserver.dpi = if (cfg.hidpi) then 200 else 90;

		fndx.packages.firefox.enable = true;

		fndx.packages.i3.enable = cfg.wm == "i3";
		fndx.packages.hyprland.enable = cfg.wm == "hyprland";
		fndx.hardware.bluetooth.enable = true;
		fndx.hardware.pulseaudio.enable = cfg.wm == "i3";
        fndx.hardware.pipewire.enable = cfg.wm == "hyprland";
		fndx.hardware.touchpad.enable = cfg.enableTouchpad && cfg.wm == "i3";
		fonts = {
			enableDefaultPackages = true;
			enableGhostscriptFonts = true;
			packages = with pkgs; [
				corefonts
				nerd-fonts.dejavu-sans-mono
				nerd-fonts.iosevka
				nerd-fonts.meslo-lg
				unifont_upper
				google-fonts
			];
		};
	}) (mkIf (cfg.enable || config.fndx.packages.i3.enable || config.fndx.packages.hyprland.enable) {
        # The greeter's display protocol is independent of the user's session.
        # An X11 SDDM greeter can launch Hyprland's registered Wayland session.
        services.xserver.enable = true;
        services.displayManager = {
            autoLogin.enable = mkDefault false;
            defaultSession = mkDefault (if config.fndx.packages.hyprland.enable then "hyprland" else "none+i3");
            sddm = {
                enable = true;
                package = mkDefault chiliSddm;
                wayland.enable = mkDefault false;
                theme = mkDefault "${cfg.sddm.themePackage}/share/sddm/themes/${cfg.sddm.theme}";
                extraPackages = mkDefault [
                    pkgs.libsForQt5.qtgraphicaleffects.out
                    pkgs.libsForQt5.qtquickcontrols.out
                    pkgs.libsForQt5.qtvirtualkeyboard.out
                ];
                settings.Theme = {
                    CursorTheme = mkDefault cfg.cursor.name;
                    CursorSize = mkDefault cfg.cursor.size;
                };
            };
        };
        environment.systemPackages = [ cfg.sddm.themePackage cfg.cursor.package ];
        home-manager.sharedModules = [ {
            home.pointerCursor = {
                gtk.enable = mkDefault true;
                x11.enable = mkDefault true;
                package = mkDefault cfg.cursor.package;
                name = mkDefault cfg.cursor.name;
                size = mkDefault cfg.cursor.size;
            };
        } ];
    }) ];
}
