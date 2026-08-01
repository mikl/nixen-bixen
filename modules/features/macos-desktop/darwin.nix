/**
  macOS desktop basics: fonts, time zone and the system preferences that are
  otherwise only recorded in `defaults`.
*/
{ ... }:
{
  flake.darwinModules.macOSDesktop =
    { pkgs, ... }:
    {
      # Installed into “/Library/Fonts/Nix Fonts” so they coexist with fonts
      # installed by other means. Use the prebuilt Iosevka, since building it
      # from source takes hours.
      fonts.packages = [
        (pkgs.iosevka-bin.override { variant = "Etoile"; })
        (pkgs.iosevka-bin.override { variant = "Slab"; })
        pkgs.adwaita-fonts
        pkgs.b612 # Covers both the proportional and the mono variant.
        pkgs.cascadia-code
        pkgs.iosevka-bin
        pkgs.nerd-fonts.iosevka-term-slab
      ];

      time.timeZone = "Europe/Copenhagen";

      networking.applicationFirewall.enable = true;

      system.defaults = {
        dock = {
          autohide = true;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.0;
          expose-group-apps = true;
          magnification = true;
          minimize-to-application = true;
          # Keep spaces in a fixed order rather than shuffling by recent use.
          mru-spaces = false;
          orientation = "bottom";
          show-recents = false;
          tilesize = 40;
        };

        finder = {
          AppleShowAllFiles = false;
          # Search the current folder rather than the whole Mac.
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          # List view.
          FXPreferredViewStyle = "clmv";
          NewWindowTarget = "Home";
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXSortFoldersFirst = true;
          _FXSortFoldersFirstOnDesktop = true;
        };

        NSGlobalDomain = {
          AppleICUForce24HourTime = true;
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          # Repeat the key instead of offering accented characters.
          ApplePressAndHoldEnabled = false;
          AppleShowAllExtensions = true;
          AppleTemperatureUnit = "Celsius";
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          # Smart dashes and quotes mangle code, so leave them off.
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;
          "com.apple.swipescrolldirection" = true;
          "com.apple.trackpad.scaling" = 1.5;
        };

        trackpad = {
          # Tap to click.
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = false;
        };

        screencapture = {
          disable-shadow = true;
          include-date = true;
          # macOS does not expand “~” in this preference, so spell it out.
          location = "/Users/mikl/Pictures/Screenshots";
          type = "png";
        };

        loginwindow.GuestEnabled = false;

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      };
    };
}
