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
	unzip
	nmap
	lsof
    ];

    fndx.packages.vim.enable = true;
    fndx.packages.zsh.enable = true;
}
