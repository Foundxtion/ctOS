# This is the workstationSettings.nix template !

{ pkgs, config, ...}:
{
    fndx.user.name = "workstation";
    # please use the following command to create your password hash
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    fndx.user.initialHashedPassword = "";
    fndx.networking = {
        hostName = "ctOS";
        useDHCP = true;
    };
    
    fndx.workstation = {
        enable = true;
    };
}
