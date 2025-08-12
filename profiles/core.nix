{config, pkgs, ...}:
{
    environment.systemPackages = with pkgs; [
		git
		htop
		man-pages
		fastfetch
		tree
		wget
		zip
		unzip
		nmap
		lsof
		jq
		autojump
    ];

    fndx.packages.vim.enable = true;
    fndx.packages.zsh.enable = true;
}
