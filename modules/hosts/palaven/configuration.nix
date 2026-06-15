{ self, inputs, ... }:
{

  flake.nixosModules.palavenConfiguration =
    { pkgs, lib, ... }:
    {
      # import any other modules from here
      imports = [
        inputs.home-manager.nixosModules.default # import official home-manager NixOS module
        self.nixosModules.en_DA_locale
        self.nixosModules.keyboard
        self.nixosModules.keydConfiguration
        self.nixosModules.palavenDisko
        self.nixosModules.palavenHardware
        self.nixosModules.tailscaleConfiguration
      ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = "palaven";

      # Use NetworkManager for WiFi and Ethernet.
      networking.networkmanager.enable = true;

      # Enable flakes.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.plasma-login-manager.enable = true;
      services.desktopManager.plasma6.enable = true;

      # Enable CUPS to print documents.
      services.printing.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
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
        initialHashedPassword = "$y$j9T$fvjXcX6L9rMnEPDmREE2D0$AH1RKlZPzav5aDXDFc7NT5hBjM9wn5q91R4PwHwt9o5";
        shell = pkgs.fish;
      };

      home-manager.users.mikl = self.homeModules.palaven;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupCommand = "${pkgs.trash-cli}/bin/trash";

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
            librewolf
            vivaldi-bin
          '';
          mode = "0755";
        };
      };

      programs.fish.enable = true;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 30d --keep 10";
        flake = "/home/mikl/Projects/Nix/nixen-bixen"; # sets NH_OS_FLAKE variable for you
      };

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

      virtualisation.docker = {
        enable = true;
      };

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "26.05"; # Did you read the comment?
    };
}
