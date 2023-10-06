{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.discord.enable = mkEnableOption "Discord for Foundxtion";
    };
}
