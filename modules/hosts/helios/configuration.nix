{ self, inputs, ... }:
{

  flake.nixosModules.heliosConfiguration =
    { lib, pkgs, ... }:
    let
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtcZZdYqj0PaP8VaZ9Rz/ubSJf1OW2WBHc5o3Ifcagt"
      ];
    in
    {
      imports = [
        inputs.home-manager.nixosModules.default
        inputs.lanzaboote.nixosModules.lanzaboote
        self.nixosModules.common
        self.nixosModules.en_DA_locale
        self.nixosModules.keyboard
        self.nixosModules.localdev
        self.nixosModules.tailscaleConfiguration
        self.nixosModules.heliosDisko
        self.nixosModules.heliosHardware
      ];

      # Secure Boot via Lanzaboote, which replaces systemd-boot. The first
      # boot generates keys in /var/lib/sbctl and stages them on the ESP;
      # systemd-boot enrolls them on the next boot, provided the firmware is
      # in Setup Mode (F10 → Advanced → Secure Boot Configuration → Clear
      # Secure Boot keys). Then turn Secure Boot on in F10.
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        # Each generation costs ~90 MB on the 1 GB ESP.
        configurationLimit = 10;
        autoGenerateKeys.enable = true;
        # Keeps the Microsoft keys, which the firmware may need to load
        # option ROMs such as the network card's.
        autoEnrollKeys.enable = true;
      };

      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "helios";
      networking.networkmanager.enable = true;

      users.users.mikl = {
        isNormalUser = true;
        description = "Mikkel T. Høgh";
        extraGroups = [
          "docker"
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = sshKeys;
      };

      # Root gets the same key so a fresh install can be reached to set a
      # password for mikl (`ssh root@helios passwd mikl`), which sudo needs.
      users.users.root.openssh.authorizedKeys.keys = sshKeys;

      home-manager.users.mikl = self.homeModules.helios;
      home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      environment.systemPackages = with pkgs; [
        # Inspect and debug Secure Boot state.
        sbctl
      ];

      programs.fish.enable = true;

      programs.nh.flake = "/home/mikl/Projects/Nix/nixen-bixen#helios";

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "prohibit-password";
        };
      };

      # HP's BIOS isn't on LVFS, but the Secure Boot dbx and the SSD
      # firmware are.
      services.fwupd.enable = true;

      virtualisation.docker.enable = true;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "26.05"; # Did you read the comment?
    };
}
