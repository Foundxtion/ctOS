{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.polybar.enable = mkEnableOption "Polybar";  
    };
}
