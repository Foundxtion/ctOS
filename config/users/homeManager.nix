{config, pkgs, ...} :
let
  secrets = import ../secrets.nix;
in
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users."${secrets.username}" = import ../homeManagerConfig;
    users.root = import ../homeManagerConfig;
  };
}
