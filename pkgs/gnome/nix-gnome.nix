{config, lib, pkgs, ...}:
let
    cfg = config.fndx.packages.gnome;
in
with lib;
{
    options = {
        fndx.packages.gnome.enable = mkEnableOption "GNOME for Foundxtion"; 
    };
}
