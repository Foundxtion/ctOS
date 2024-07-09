{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.gtk;
in
with lib;
{
    options = {
        fndx.packages.gtk.enable = mkEnableOption "GTK Themed for ctOS";
    };

    config = mkIf cfg.enable {
        programs.dconf.enable = true;
        environment.sessionVariables = rec {
            GTK_THEME = "WhiteSur-Dark";
            # GDK_SCALE = "2"; This also adjusts scaling of things like Firefox...
        };
    };
}
