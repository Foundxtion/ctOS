{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.waybar.enable = mkEnableOption "Waybar";  
    };
}
