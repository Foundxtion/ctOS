{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
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
    lsof
  ];

  # specify files to be imported into /etc/ folder
  environment.etc = {
    "secrets.nix" = {
      source = ./secrets.nix;
      mode = "0666";
    };
  };

  networking = let 
    hostName = "foundation-installer";
    networkmanager.enable = true;
    wireless.enable = false;
  in
  if secrets.network.hasStaticAddress then {
    inherit hostName networkmanager wireless;
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = secrets.network.ipAddress;
      prefixLength = secrets.network.prefixLength;
    }];
    defaultGateway = secrets.network.defaultGateway;
    nameservers = [ "8.8.8.8" ];
  }
  else {
    inherit hostName networkmanager wireless;
  };

  # this enables an ssh access in the boot process
  # whose root session is only accessible by the builder
  # of the iso
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    secrets.authorizedKey
  ];

  systemd.services.install = {
    description = "NixOS installation bootstrap";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "polkit.service" "NetworkManager.service"];
    path = ["/run/current-system/sw/"];
    script = with pkgs; ''
        dev="/dev/sda";

        echo "Waiting 5 seconds for connection establishment";
        sleep 5;

        echo "Testing connection...";
        ping -c 3 github.com;
        echo "Test passed!";

        echo "Creating partitions...";
        
        # we put yes in stdin in case there is already a partition table to override
        ${parted}/bin/parted "$dev" -s -- mklabel gpt;
        ${parted}/bin/parted "$dev" -- mkpart primary 512MB -8GB;

        ${parted}/bin/parted "$dev" -- mkpart primary linux-swap -8GB 100%;
        ${parted}/bin/parted "$dev" -- mkpart ESP fat32 1MB 512MB;
        ${parted}/bin/parted "$dev" -- set 3 esp on;

        echo "Formatting partitions...";
        mkfs.ext4 -L nixos "$dev"1;
        mkswap -L swap "$dev"2;
        mkfs.fat -F 32 -n boot "$dev"3;

        echo "Mouting filesystems...";
        mount "$dev"1 /mnt;
        mkdir -p /mnt/boot;
        mount "$dev"3 /mnt/boot;
        swapon "$dev"2;

        echo "Generating config...";
        ${config.system.build.nixos-generate-config}/bin/nixos-generate-config --root /mnt;
        git clone https://github.com/LilianSchall/foundation /mnt/root/.config;
        cp /etc/secrets.nix /mnt/root/.config/config/;
        mv /mnt/etc/nixos/hardware-configuration.nix /mnt/root/.config/config/;
        rm -rf /mnt/etc/nixos;
        cd /mnt/etc;
        ln -sr ../root/.config/config /mnt/etc/nixos;

        echo "Installing NixOS...";
        ${config.system.build.nixos-install}/bin/nixos-install --no-root-passwd;

        echo "Rebooting...";
        reboot;
      '';

      environment = config.nix.envVars // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/root";
      };
  };

}
