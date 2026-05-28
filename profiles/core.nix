{config, pkgs, ...}:
{
    environment.systemPackages = with pkgs; [
		ncdu
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
		glow # markdown terminal rendering
    ];

    fndx.packages.vim.enable = true;
    fndx.packages.zsh.enable = true;
	fndx.packages.lix.enable = true;
}
