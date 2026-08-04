{ self, inputs, ... }:
{
  flake.darwinModules.korhalConfiguration =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.default
        self.darwinModules.macOSDesktop
      ];

      nixpkgs.hostPlatform = "aarch64-darwin";

      # Same as the NixOS hosts do in modules/features/common/nixos.nix.
      nixpkgs.config.allowUnfree = true;

      # Nix here is Determinate Nix, which owns the daemon, /etc/nix/nix.conf and
      # the nixbld users. Letting nix-darwin manage those too would clobber them,
      # so extra Nix settings go in /etc/nix/nix.custom.conf instead.
      nix.enable = false;

      networking.hostName = "korhal";
      networking.computerName = "Korhal";

      # Which user the `system.defaults` and other per-user settings apply to.
      system.primaryUser = "mikl";

      # Makes the Nix fish a permissible login shell, listed in /etc/shells.
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];

      # Listing mikl in knownUsers lets nix-darwin set the login shell, so it
      # does not have to be done by hand with chsh. It also means the uid has to
      # match the account, otherwise activation skips the user with a warning.
      # Dropping the user from users.users while leaving it here would delete the
      # account, but system.primaryUser above makes that an evaluation error.
      users.knownUsers = [ "mikl" ];

      users.users.mikl = {
        uid = 502;
        home = "/Users/mikl";
        shell = pkgs.fish;
      };

      home-manager.users.mikl = self.homeModules.korhalHomeManager;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";

      # Whatever is not reasonably available from nixpkgs. Cleanup is “none”, so
      # nix-darwin installs what is listed here but never uninstalls anything
      # else — removing the packages that moved to Nix is a deliberate manual
      # `brew uninstall`.
      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = false;
          cleanup = "uninstall";
          upgrade = false;
        };

        taps = [
          "textfuel/tap"
          "uselagoon/lagoon-cli"
        ];

        brews = [
          # Not packaged in nixpkgs.
          "asimov"
          "textfuel/tap/lazyjira"
          "uselagoon/lagoon-cli/lagoon"
        ];

        casks = [
          # Fonts not packaged in nixpkgs.
          "font-playwrite-dk-loopet"
          "font-strichpunkt-sans"
        ];
      };

      # Used to determine which nix-darwin defaults apply. Leave it alone.
      system.stateVersion = 7;
    };
}
