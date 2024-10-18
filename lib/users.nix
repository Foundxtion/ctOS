{config, lib, pkgs, ...}:
let
    cfg = config.fndx.user;
in
with lib;
{
    options = {
        fndx.user.name = mkOption {
            default = "fndx";
            type = types.str;
            description = mdDoc "ctOS username";
        };
        fndx.user.initialHashedPassword = mkOption {
            example = "x";
            type = types.str;
            description = mdDoc ''
                Hash of the first password for the user. Please change your password immediately after first connection.
            '';
        };
    };

    config = {
        users.defaultUserShell = pkgs.zsh;
        
        users.users."${cfg.name}" = {
            initialHashedPassword = mkIf (cfg.initialHashedPassword != "") cfg.initialHashedPassword;
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" "dialout" ] ++ optionals (config.fndx.services.docker.enable) [ "docker" ];
            openssh.authorizedKeys.keys = mkIf config.fndx.services.openssh.enable config.fndx.services.openssh.authorizedKeys;
        };
        home-manager.users."${cfg.name}" = import ../pkgs/homeManager.nix;
        home-manager.users.root = import ../pkgs/homeManager.nix;
    };
}
