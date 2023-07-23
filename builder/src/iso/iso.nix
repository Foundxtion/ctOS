{ config, pkgs, ... }:
let
  secrets = import ./builder-secrets.nix;
in
{
  imports = [
    # Standard minimal nix installer
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide a copy of the NixOS channel as described in the wiki:
    # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
    # The user will not need to update its channel during installation
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  nixpkgs.config.allowUnfree = true;

  # specify what packages needs to be imported
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # specify files to be imported into /etc/ folder
  environment.etc = {
    foundation_installer.source = ./foundation_installer.sh;
    config.source = ../../config;
  };

  networking = {
    hostName = "foundation-installer";
    networkmanager.enable = true;
    wireless.enable = false;
    # usePredictableInterfaceNames = false;
    # interfaces.eth0.ip4 = [
    #   {
    #     address = secrets.network.ipAddress;
    #     prefixLength = secrets.network.prefixLength;
    #   }
    # ];
    # defaultGateway = secrets.network.defaultGateway;
    # nameservers = [ "8.8.8.8" ];
  };

  # this enables an ssh access in the boot process
  # whose root session is only accessible by the builder
  # of the iso
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    secrets.authorizedKey
  ];

}
