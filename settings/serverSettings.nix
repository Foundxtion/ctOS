# This is the serverSettings.nix template !

{ pkgs, config, ...}:
let
    domain = "example.com";
in
{
    fndx.user.name = "webServer";
    # please use the following command to create your password hash
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    fndx.user.initialHashedPassword = "";
    fndx.networking = {
        hostName = "foundxtion";
        useDHCP = false;
        ipv4Address = "192.168.1.192";
        prefixLength = 24;
        defaultGateway = "192.168.1.1";
    };

    fndx.webServer = {
        enable = true;
        domain = domain;
        acme-email = "user@example.com";
        dynamicDns = {
            enable = true;
            protocol = "namecheap";
            password = "password";
        };
        virtualHosts = {
          # NixOS nginx configuration for now
        };
    };
    fndx.services.mailserver = {
        enable = true;
        domain = domain;
        loginAccounts = {};
    };
    fndx.services.openssh = {
        enable = true;
        authorizedKeys = [""];
    };
    fndx.services.docker.enable = true;
}
