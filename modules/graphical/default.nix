{config, lib, pkgs, ...}:
let
    cfg = config.fndx.graphical;
in
with lib;
{
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
	};

	config = mkIf cfg.enable {
		environment.systemPackages = with pkgs; [
			google-chrome
			feh
		];

        services.xserver.dpi = if (cfg.hidpi) then 200 else 90;

		fndx.packages.firefox.enable = true;

		fndx.packages.i3.enable = cfg.wm == "i3";
		fndx.packages.hyprland.enable = cfg.wm == "hyprland";
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
