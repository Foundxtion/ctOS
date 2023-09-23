{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.alacritty.enable = mkEnableOption "Alacritty for Foundxtion";
    };
}
