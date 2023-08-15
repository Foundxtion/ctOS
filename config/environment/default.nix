{ config, pkgs, ... } :
{
  environment = {
    systemPackages = with pkgs; [
      htop
      git
      tree
      vim
      man-pages
      zip
    ];
  };
}
