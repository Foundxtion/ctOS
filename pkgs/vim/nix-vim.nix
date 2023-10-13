{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.vim.enable = mkEnableOption "Vim";
    };
}
