{config, pkgs, ...}:
{
  imports = [ 
    ./core.nix
    ./webServer.nix
  ];
}
