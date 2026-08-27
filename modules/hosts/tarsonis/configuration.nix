{ self, inputs, ... }:
{

  flake.nixosModules.tarsonisConfiguration =
    { pkgs, lib, ... }:
    {
      # import any other modules from here
      imports = [
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        inputs.home-manager.nixosModules.default # import official home-manager NixOS module
        inputs.ldddns.nixosModules.default
        self.nixosModules.common
        self.nixosModules.en_DA_locale
        self.nixosModules.ergodoxResumeFix
        self.nixosModules.frameworkFingerprintResumeFix
        self.nixosModules.keyboard
        self.nixosModules.keydConfiguration
        self.nixosModules.localdev
        self.nixosModules.linuxDesktopPwas
        self.nixosModules.luksAutoLogin
        self.nixosModules.niriConfiguration
        self.nixosModules.nixOSWallpaper
        self.nixosModules.plymouthBoot
        self.nixosModules.tailscaleConfiguration
        self.nixosModules.tarsonisDisko
        self.nixosModules.tarsonisHardware
      ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Cap systemd-boot entries so /boot (a 1 GB ESP) cannot fill up: each
      # new kernel version costs ~88 MB of non-dedupable kernel + initrd.
      boot.loader.systemd-boot.configurationLimit = 20;

      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "tarsonis";

      # Use NetworkManager for WiFi and Ethernet.
      networking.networkmanager.enable = true;

      # The Plasma *desktop* is gone from this host; Niri is the only session
      # (see modules/features/niri). The login manager is a separate module and
      # stays, because modules/features/luks-auto-login hangs off its
      # `plasmalogin-autologin` PAM stack: greetd would autologin without ever
      # running pam_authenticate, so pam_systemd_loadkey and pam_kwallet5 — both
      # auth-phase modules — would never fire and KWallet would stay locked.
      services.displayManager.plasma-login-manager.enable = true;

      # Log straight in after the LUKS passphrase; see the luksAutoLogin module.
      services.displayManager.autoLogin = {
        enable = true;
        user = "mikl";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      services.fprintd.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.mikl = {
        isNormalUser = true;
        description = "Mikkel T. Høgh";
        extraGroups = [
          "docker"
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.fish;
      };

      home-manager.users.mikl = self.homeModules.tarsonis;
      home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      # Install firefox.
      programs.firefox.enable = true;

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        framework-tool-tui
      ];

      programs.fish.enable = true;

      programs.nh.flake = "/home/mikl/Projects/Nix/nixen-bixen#tarsonis"; # sets NH_OS_FLAKE variable for you

      # Enable Avahi for use with ldddns.
      services.avahi = {
        enable = true;
        nssmdns4 = true; # plugs avahi into NSS for .local lookups.
        publish = {
          # lddds needs user services enabled.
          enable = true;
          addresses = true;
          userServices = true;
        };
      };

      services.hardware.bolt.enable = true;
      services.ldddns.enable = true;

      # Framework ships firmware through LVFS, so fwupd earns its place on this
      # host specifically. The Niri module no longer enables it; on eidolon
      # plasma6 still switches it on at `mkDefault true`.
      services.fwupd.enable = true;

      # Enable the OpenSSH daemon.
      services.openssh = {
        enable = true;
        settings = {
          #PasswordAuthentication = false;
          #KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          #AllowUsers = [ "cwmyUser" ];
        };
      };

      # KDE Partition Manager needs to be installed system wide, since it ships with a service.
      programs.partition-manager.enable = true;

      services.resolved = {
        enable = true;
        # Tell resolved to leave .local alone, avoid overlap with Avahi.
        settings = {
          Resolve = {
            LLMNR = "no";
            MulticastDNS = "no";
          };
        };
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?

      systemd.services.battery-charge-threshold = {
        description = "Set battery charge limit to 77%";
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo 77 > /sys/class/power_supply/BAT1/charge_control_end_threshold'";
        };
      };

      virtualisation.docker = {
        enable = true;
      };
    };
}
