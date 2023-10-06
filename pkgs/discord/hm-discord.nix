{osConfig, lib, pkgs, ...}:
with lib;
{
    home.packages = [] ++ optionals osConfig.fndx.packages.discord.enable (with pkgs;[discord]);
}
