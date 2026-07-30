{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.hyprland;
in
with lib;
{
    options = {
        fndx.packages.hyprland = {
            enable = mkEnableOption "Hyprland for ctOS";
            openSshTab = {
                enable = mkEnableOption "Opening of an alacritty directly connecting to an ssh session";
                userName = mkOption {
                    example = "user";
                    type = types.str;
                    description = mdDoc "The user to connect during the ssh session";
                };
                domainName = mkOption {
                    example = "example.org";
                    type = types.str;
                    description = mdDoc "The domain on which to connect during the ssh session";
                };
            };
        };
    };

    config = mkIf cfg.enable {
        services = {
		  xserver.enable = false;
          greetd = {
            enable = true;
            settings = {
              default_session = {
                user = "lilian";
                command = "$HOME/.wayland-session";
              };
            };
          };
        };
		xdg.portal = {
			enable = true;
			extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
			config.common.default = [ "hyprland" ];
		};

		fndx.packages.rofi.enable = true;
        fndx.packages.alacritty.enable = true;
        fndx.packages.nautilus.enable = true;
        fndx.packages.gtk.enable = true;

		environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };
}
