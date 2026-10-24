{config, lib, pkgs, ...}:
{
    imports = [
        ./ddclient.nix
        ./docker.nix
        ./jupyterhub.nix
        ./k3s
        ./mailserver.nix
        ./netauth.nix
        ./nginx.nix
        ./openssh.nix
        ./portainer.nix
		# ./rping.nix
        ./vpn-client.nix
        ./vpn-server.nix
    ];
}
