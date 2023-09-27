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

        firefox
    ];

    fndx.packages.vim.enable = true;
    fndx.packages.zsh.enable = true;
}
