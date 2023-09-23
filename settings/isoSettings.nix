# This is the iso-settings.nix template !
# Comment out the configuration you might use

{ pkgs, config, ...}:
{
    imports = [ ../installer ];
    fndx.networking = {
        # Enable / disable Network IP Attribution... (default: true)
        useDHCP = true;
        # ... Or (advanced) use static address !
        #ipv4Address = "255.255.255.255";
        #prefixLength = 0;
        #defaultGateway = "255.255.255.255";
    };

    installer = {
        # What git remote to use as your Foundxtion configuration ?
        git-remote = "https://github.com/foundxtion/foundxtion";

        # Are you installing a server ?
        # If yes, you may want to enable ssh into root (default: false)
        ssh = {
            enable = false;
            usedRootKey = "";
        };
    };
}
