{config, lib, pkgs, ...}:
let
    cfg = config.fndx.graphical;
in
with lib;
{
	options = {
		fndx.graphical.enable = mkEnableOption "ctOS graphic interface";
		fndx.graphical.enableTouchpad = mkEnableOption "touchpad on ctOS graphical interface";
		fndx.graphical.type = mkOption {
			example = "gnome";
			type = types.str;
			description = mdDoc "Whether to enable GNOME or i3 interface";
		};
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
	};

	config = mkIf cfg.enable {
		assertions = [ {
			assertion = ((cfg.type == "i3") || (cfg.type == "gnome") || (cfg.type == "plasma"));
			message = "If ctOS graphic interface is enabled, please select either i3, plasma or gnome type.";
		}];

		services.xserver = {
			enable = true;
			desktopManager.xterm.enable = false;
			xkb = {
				layout = "us";
				variant = "";
			};
			autorun = true;
			dpi = if (cfg.hidpi) then 200 else 90;
			excludePackages = with pkgs; [
				xterm
			];
		};

		environment.systemPackages = with pkgs; [
			google-chrome
			feh
		];

		fndx.packages.firefox.enable = true;

		fndx.packages.i3.enable = mkIf (cfg.type == "i3") true;
		fndx.packages.gnome.enable = mkIf (cfg.type == "gnome") true;
		fndx.packages.plasma.enable = mkIf (cfg.type == "plasma") true;
		fndx.hardware.bluetooth.enable = true;
		fndx.hardware.pulseaudio.enable = true;
		fndx.hardware.touchpad.enable = cfg.enableTouchpad;
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
	};
}
