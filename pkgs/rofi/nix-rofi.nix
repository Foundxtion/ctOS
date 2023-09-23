{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.rofi.enable = mkEnableOption "Rofi for Foundxtion"; 
    };
}
