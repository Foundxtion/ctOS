{ config, lib, pkgs, ...}:
{
    imports = [
        # Standard minimal nix installer
        <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

        # Provide a copy of the NixOS channel as described in the wiki:
        # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
        # The user will not need to update its channel during installation
        <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
        # Installer imports
        ./installation.nix
        ./ssh.nix
        # Core imports
        ../modules
        ../pkgs
    ];

    environment.systemPackages = with pkgs; [
        vim
        git
        lsof
        htop        
    ];

    fndx.networking.hostName = "fndx-installer";

    environment.etc = {
        "settings.nix" = {
            source = ../settings.nix;
            mode = "0600";
        };
    };
}
