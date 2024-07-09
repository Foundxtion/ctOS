{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.plasma;
in
with lib;
{
    options = {
        fndx.packages.plasma.enable = mkEnableOption "Plasma for ctOS";
    };

    config = mkIf cfg.enable {
        services.xserver = {
            enable = true;
            displayManager.sddm = {
                enable = true;
                theme = "WhiteSur";
            };
            desktopManager.plasma5.enable = true;
        };

        environment.plasma5.excludePackages = with pkgs.libsForQt5; [
            elisa
            gwenview
            okular
            oxygen
            khelpcenter
            konsole
            plasma-browser-integration
            print-manager
        ];

        fndx.packages.rofi.enable = true;
        fndx.packages.alacritty.enable = true;

       environment.systemPackages = [
            pkgs.whitesur-kde
            pkgs.whitesur-icon-theme
            pkgs.libsForQt5.qtstyleplugin-kvantum
        ];
    };
}
