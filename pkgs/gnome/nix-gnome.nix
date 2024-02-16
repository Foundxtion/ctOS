{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.gnome;
in
with lib;
{
    options = {
        fndx.packages.gnome.enable = mkEnableOption "GNOME for Foundxtion"; 
    };

    config = mkIf cfg.enable {
        services.xserver = {
            displayManager = {
                autoLogin.enable = false;
                gdm = {
                    enable = true;
                };
            };

            desktopManager = {
                gnome.enable = true;
            };
        };
		environment.gnome.excludePackages = (with pkgs; [
			  	gnome-photos
			   	gnome-tour
		]) ++ (with pkgs.gnome; [
			   	cheese # webcam tool
			   	gnome-music
			   	gnome-terminal
			   	gedit # text editor
			   	epiphany # web browser
			   	geary # email reader
			   	evince # document viewer
			   	gnome-characters
			   	totem # video player
			   	tali # poker game
			   	iagno # go game
			   	hitori # sudoku game
			   	atomix # puzzle game
		]);
        fndx.packages.alacritty.enable = true;
        fndx.packages.gtk.enable = true;
    };
}
