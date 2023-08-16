{config, pkgs, ...} :
{
  users.users.home-manager = {
    isNormalUser = false;
    description = "home-manager user";
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.foundation = import ../homeManagerConfig;
    users.root = import ../homeManagerConfig;
  };
}
