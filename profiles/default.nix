{config, pkgs, ...}:
{
  imports = [ 
    ./core.nix
    ./webServer.nix
    ./dev.nix
  ];
}
