{ self, inputs, ... }:
{

  flake.nixosModules.eidolonConfiguration =
    { pkgs, lib, ... }:
    {
      # import any other modules from here
      imports = [
        inputs.home-manager.nixosModules.default # import official home-manager NixOS module
        self.nixosModules.caddyServer
        self.nixosModules.common
        self.nixosModules.en_DA_locale
        self.nixosModules.eidolonHardware
        self.nixosModules.keyboard
        self.nixosModules.localdev
        self.nixosModules.syncthing
        self.nixosModules.tailscaleConfiguration
      ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Cap systemd-boot entries so /boot (a 1 GB ESP) cannot fill up: each
      # new kernel version costs ~88 MB of non-dedupable kernel + initrd.
      boot.loader.systemd-boot.configurationLimit = 20;

      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "eidolon";

      # Wired ethernet on DHCP only, so systemd-networkd rather than
      # NetworkManager: no roaming, no secrets, nothing to click. The default
      # networking.useDHCP makes the networkd module emit a
      # 99-ethernet-default-dhcp unit matching every physical ether interface,
      # so there is no interface name to hardcode and nothing else to declare.
      networking.useNetworkd = true;

      # No graphical session: this box is reached over SSH and Tailscale only,
      # so there is no login manager, no desktop and no audio stack. The
      # console keymap from the keyboard module is all the local access needs.

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.mikl = {
        isNormalUser = true;
        description = "Mikkel T. Høgh";
        extraGroups = [
          "wheel"
        ];
        shell = pkgs.fish;

        # Syncthing runs as a user service and this box has no interactive
        # logins to start the user manager. Lingering keeps it running from
        # boot.
        linger = true;
      };

      home-manager.users.mikl = self.homeModules.eidolon;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";

      programs.fish.enable = true;

      programs.nh.flake = "/home/mikl/Projects/Nix/nixen-bixen#eidolon"; # sets NH_OS_FLAKE variable for you

      # Enable the OpenSSH daemon. With the desktop gone this is the only way
      # in apart from the physical console.
      services.openssh = {
        enable = true;
        settings = {
          #PasswordAuthentication = false;
          #KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          #AllowUsers = [ "cwmyUser" ];
        };
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?
    };
}
