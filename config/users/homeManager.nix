{config, pkgs, ...} :
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.foundation = import ../homeManagerConfig;
    users.root = import ../homeManagerConfig;
  };
}
