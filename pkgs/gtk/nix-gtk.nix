{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.gtk;
in
with lib;
{
    options = {
        fndx.packages.gtk.enable = mkEnableOption "GTK Themed for Foundxtion";
    };

    config = mkIf cfg.enable {
        programs.dconf.enable = true;
    };
}
