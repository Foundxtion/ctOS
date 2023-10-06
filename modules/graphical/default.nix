{config, lib, pkgs, ...}:
let
    cfg = config.fndx.graphical;
in
with lib;
{
    options = {
        fndx.graphical.enable = mkEnableOption "Foundxtion graphic interface";
        fndx.graphical.enableTouchpad = mkEnableOption "touchpad on Foundxtion graphical interface";
        fndx.graphical.type = mkOption {
            example = "gnome";
            type = types.str;
            description = mdDoc "Whether to enable GNOME or i3 interface";
        };
        fndx.graphical.background = mkOption {
            default = ../../wallpapers/fire.jpg;

            description = mdDoc "Foundxtion background for graphical interface";
        };
    };

    config = mkIf cfg.enable {
        assertions = [ {
            assertion = ((cfg.type == "i3") || (cfg.type == "gnome"));
            message = "If Foundxtion graphic interface is enabled, please select either i3 or gnome type.";
        }];

        services.xserver = {
            enable = true;
            desktopManager.xterm.enable = false;
            layout = "us";
            xkbVariant = "";
            autorun = true;
        };

        environment.systemPackages = with pkgs; [
            firefox
        ];

        fndx.packages.i3.enable = mkIf (cfg.type == "i3") true;
        fndx.packages.gnome.enable = mkIf (cfg.type == "gnome") true;
        fndx.hardware.bluetooth.enable = true;
        fndx.hardware.pulseaudio.enable = true;
        fndx.hardware.touchpad.enable = cfg.enableTouchpad;
		fonts = {
		    enableDefaultFonts = true;
		    enableGhostscriptFonts = true;
		    fonts = with pkgs; [
		      corefonts
		      (nerdfonts.override { fonts = [ "DejaVuSansMono" "Iosevka" "Meslo" ]; })
		      unifont_upper
		    ];
		};
    };
}
