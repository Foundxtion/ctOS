{ config, pkgs, ... } :
{
  environment = {
    systemPackages = with pkgs; [
      git
      htop
      man-pages
      neofetch
      tree
      vim
      zip
    ];
  };
}
