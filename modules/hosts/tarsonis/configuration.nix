{ self, inputs, ... }:
{

  flake.nixosModules.tarsonisConfiguration =
    { pkgs, lib, ... }:
    {
      # import any other modules from here
      imports = [
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        inputs.home-manager.nixosModules.default # import official home-manager NixOS module
        self.nixosModules.nixOSWallpaper
        self.nixosModules.tarsonisHardware
      ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.luks.devices."luks-e0cefc69-fbde-4c4f-bf27-89b5b7a49dfe".device =
        "/dev/disk/by-uuid/e0cefc69-fbde-4c4f-bf27-89b5b7a49dfe";

      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "tarsonis";

      # Use NetworkManager for WiFi and Ethernet.
      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Copenhagen";
      i18n.defaultLocale = "en_DK.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "da_DK.UTF-8";
        LC_IDENTIFICATION = "da_DK.UTF-8";
        LC_MEASUREMENT = "da_DK.UTF-8";
        LC_MONETARY = "da_DK.UTF-8";
        LC_NAME = "da_DK.UTF-8";
        LC_NUMERIC = "da_DK.UTF-8";
        LC_PAPER = "da_DK.UTF-8";
        LC_TELEPHONE = "da_DK.UTF-8";
        LC_TIME = "da_DK.UTF-8";
      };

      # Enable flakes.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Enable the X11 windowing system.
      # You can disable this if you're only using the Wayland session.
      services.xserver.enable = true;

      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "mac-iso";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;
      };

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
      home-manager.backupFileExtension = "bak";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      # Install firefox.
      programs.firefox.enable = true;

      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = [ "mikl" ];
      };

      environment.etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            vivaldi-bin
          '';
          mode = "0755";
        };
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        btop
        curl
        git
        neovim
        wget
      ];

      programs.fish.enable = true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 30d --keep 10";
        flake = "/home/mikl/Projects/Nix/nixen-bixen#tarsonis"; # sets NH_OS_FLAKE variable for you
      };

      services.hardware.bolt.enable = true;

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

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.11"; # Did you read the comment?

      virtualisation.docker = {
        enable = true;
      };
    };
}
