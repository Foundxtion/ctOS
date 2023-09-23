{ config, lib, pkgs, ...}:
with lib;
{
    options = {
        installer.ssh = {
            enable = mkEnableOption "Root SSH access";
            usedRootKey = mkOption {
                default = "";
                type = types.str;
                description = mdDoc ''
                    SSH cryptographic key used to connect to root user.
                '';
            };
        };
    };

    config = mkIf config.installer.ssh.enable {
        systemd.services.ssh.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
        users.users.root.openssh.authorizedKeys.keys = [ config.installer.ssh.usedRootKey ];
    };
}
