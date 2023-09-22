{config, lib, pkgs, ...}:
with lib;
{
    options = {
        fndx.packages.vim.enable = mkEnableOption "Vim";
    };

    config = mkIf config.fndx.packages.vim.enable {
        programs.neovim = {
            enable = true;
            defaultEditor = true;
            vimAlias = true;
        };
    };
}
