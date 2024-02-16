{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.gtk.enable = mkEnableOption "GTK Themed for Foundxtion";
    };
}
