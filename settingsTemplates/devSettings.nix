# This is the devSettings.nix template !

{ pkgs, config, ...}:
{
    fndx.user.name = "dev";
    # please use the following command to create your password hash
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    fndx.user.initialHashedPassword = "";
    fndx.networking = {
        hostName = "ctOS";
        useDHCP = true;
    };
    
    fndx.dev = {
        enable = true;
        cpp.enable = true;
        csharp.enable = true;
        java.enable = true;
        web.enable = true;
        rust.enable = true;
    };

    fndx.netauth = {
        enable = true;
        realm = "EXAMPLE.COM";
    };
}
