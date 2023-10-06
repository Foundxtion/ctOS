{config, pkgs, ...}:
{
    environment.systemPackages = with pkgs; [
        git
        htop
        man-pages
        neofetch
        tree
        wget
        zip
    ];

    fndx.packages.vim.enable = true;
    fndx.packages.zsh.enable = true;
}
