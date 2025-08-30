# ctOS: The Central Operating system

This repository contains an opinionated configuration for nix-based systems.
It includes NixOS configurations along with Home-manager configuration.

ctOS is built for one-user systems only.

With ctOS, with the same configuration, you can easily deploy:

- Servers for hosting preconfigured services, or your custom services using
  NixOS infrastructure as code system.
- Dev workstations that are strongly configured to provide software engineers a
  streamlined work environment.

## How to install

Basically, there is two ways to install ctOS on your system.

### On new installation (requires nix to build base image)

Work in progress

### On already existing installation

You have already a nixos installation up and running consisting of a
`configuration.nix` and `hardware-configuration.nix` file.

In order to migrate towards ctOS, you simply need to execute the following
commands while being root. (you can run the `su` commmand to become root)

```sh
# Let's assume root user has not git installed.
nix-shell -p git

# Assuming you have your .nix files in /etc/nixos/ folder.
cd /etc && mv nixos old-nixos/

git clone https://github.com/foundxtion/ctOS.git nixos
cp old-nixos/hardware-configuration.nix nixos/

# ctOS runs with a special settings.nix file that is found in root folder. 
mkdir -p /root/settings

# We copy a template for the dev profile, if you want to configure a server
# instead, please use the the serverSettings.nix template file.
cd nixos/ && cp settingsTemplate/devSettings.nix /root/settings/settings.nix && ln -s
../../root/settings/settings.nix settings.nix
```
At that step, ctOS files are now on your system, but is not yet fully installed.
You need now to configure your system using the `/root/settings/settings.nix`
file.

Please fill up the options with your custom data such as hostname, username, and
initialHashedPassword.
Remove or comment options from template that is not useful to you (documentation
is WIP)

### For graphics

Please add the following property in your `settings.nix` file
based on your graphics card.

```nix
# For NVIDIA graphics cards
fndx.hardware.nvidia.enable = true;

# For AMD graphics cards
fndx.hardware.amd.enable = true;
```

### For systems installed in a VM

If you are using a vmware software, please add the following property in your
`settings.nix` file:

```nix
virtualisation.vmware.guest.enable = true;
```

When you're satisfied with your `settings.nix`, run `nixos-rebuild boot` as root
and reboot later.

## How to daily drive this system

ctOS is built as a heavily opinionated system that provides an ergonomical
configuration for developers and server admins.

### For servers

ctOS provides numerous server services like mailserver, AD like identity
provider, docker instance monitoring, etc...

#### Netauth server

Netauth is a Foundxtion service that acts as an Identity and Access Provider,
combining OpenLDAP and Kerberos.
To enable it on your system, please add the following property in your
`settings.nix` file.

```nix
fndx.services.netauth = {
    enable = true;
    realm = "EXAMPLE.ORG";
    organisationName = "Example";
    adminPassword = "password123";
    masterPassword = "password123";
    kdcPassword = "password123";
    kadminPassword = "password123";
};
```

### For developers

ctOS is built upon i3 wm.

#### Netauth client

To configure your dev station to connect to a netauth instance, please add the
following property in your `settings.nix` file.

```nix
fndx.netauth = {
    enable = true;
    realm = "EXAMPLE.ORG";
};
```
