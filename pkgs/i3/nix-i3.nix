{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.i3;
in
with lib;
{
    options = {
        fndx.packages.i3 = {
            enable = mkEnableOption "i3 for Foundxtion";
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
        
        services.displayManager = {
            autoLogin.enable = false;
            sddm = {
                enable = true;
                theme = "chili";
            };
            defaultSession = "none+i3";
        };

        services.xserver = {
            upscaleDefaultCursor = true;

            windowManager.i3 = {
                enable = true;
                package = pkgs.i3-gaps;
                extraPackages = with pkgs; [
                    spectacle
                    i3lock-fancy-rapid
		    blugon
                ];
                extraSessionCommands = ''
                  ${pkgs.feh}/bin/feh --bg-scale --fill ${config.fndx.graphical.background}
                '';
            };
        };

	programs.light.enable = true;
        fndx.packages.rofi.enable = true;
        fndx.packages.alacritty.enable = true;
        fndx.packages.picom.enable = true;
        fndx.packages.nautilus.enable = true;
        fndx.packages.gtk.enable = true;
        fndx.packages.polybar.enable = true;

        environment.systemPackages = with pkgs; [
            (sddm-chili-theme.override {
                themeConfig = {
                    background = config.fndx.graphical.loginBackground;
                };
            })
        ];
    };
}
