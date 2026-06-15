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
        self.nixosModules.palavenDisko
        self.nixosModules.palavenHardware
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

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.mikl = {
        isNormalUser = true;
        description = "Mikkel T. Høgh";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        initialHashedPassword = "$y$j9T$fvjXcX6L9rMnEPDmREE2D0$AH1RKlZPzav5aDXDFc7NT5hBjM9wn5q91R4PwHwt9o5";
        shell = pkgs.fish;
      };

      home-manager.users.mikl = self.homeModules.palaven;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";

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

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "26.05"; # Did you read the comment?
    };
}
