{config, lib, pkgs, ...}:
with lib;
{
    options = {
        installer.git-remote = mkOption {
            default = "https://github.com/Foundxtion/Foundxtion";
            type = types.str;
            description = mdDoc ''
                What remote to clone and use as configuration for your Foundxtion system ?
            '';
        };
    };

    config = {
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
    
                echo "Adding home-manager channel...";
                nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager;
                nix-channel --update;
    
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
                git clone ${config.installer.git-remote} /mnt/root/nixos;
                cp /etc/settings.nix /mnt/root/nixos/settings;
                mv /mnt/etc/nixos/hardware-configuration.nix /mnt/root/nixos/entrypoint;
                rm -rf /mnt/etc/nixos;
                cd /mnt/etc;
                ln -sr ../root/nixos/entrypoint /mnt/etc/nixos;
    
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
    };
}
