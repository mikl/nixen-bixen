/**
  Konfiguration for KDE desktop environment.

  Color schemes follow the Eldritch palettes and semantic roles:
  https://github.com/eldritch-theme/eldritch
*/
{ self, inputs, ... }:
{
  flake.homeModules.linuxDesktopKDE =
    { lib, pkgs, ... }:
    let
      # Eldritch palettes as `#RRGGBB`, matching the spec.
      palettes = {
        cthulhu = {
          background = "#212337"; # Sunken Depths Grey
          currentline = "#323449"; # Shallow Depths Grey
          surface = "#454759"; # Tidal Surface
          overlay = "#5b5c66"; # Murk Overlay
          foreground = "#ebfafa"; # Lighthouse White
          comment = "#7081d0"; # The Old One Purple
          cyan = "#04d1f9"; # Watery Tomb Blue
          green = "#37f499"; # Great Old One Green
          orange = "#f7c67f"; # Dreaming Orange
          pink = "#f265b5"; # Pustule Pink
          purple = "#a48cf2"; # Lovecraft Purple
          red = "#f16c75"; # R'lyeh' Red
          yellow = "#f1fc79"; # Gold of Yuggoth
        };
        abyss = {
          background = "#171928"; # Void Black
          currentline = "#252738"; # Deep Sea Grey
          surface = "#353746"; # Benthic Surface
          overlay = "#474852"; # Hadal Overlay
          foreground = "#d8e6e6"; # Pale Specter
          comment = "#506299"; # Forgotten Rune
          cyan = "#0396b3"; # Abyssal Teal
          green = "#2dcc82"; # Phosphor Green
          orange = "#d4a666"; # Amber Ichor
          pink = "#d154a1"; # Dreamrot Pink
          purple = "#8b75d9"; # Shadow Violet
          red = "#cc5860"; # Crimson Omen
          yellow = "#ccd663"; # Sulfur Yellow
        };
        dusk = {
          background = "#f0f3f4"; # Pale Shore
          currentline = "#e2e6e8"; # Coastal Mist
          surface = "#d5d9db"; # Tidal Flat
          overlay = "#c9cbcd"; # Dusk Haze
          foreground = "#1e2029"; # Abyssal Ink
          comment = "#5b73dc"; # Faded Rune
          cyan = "#0ad6ff"; # Twilight Teal
          green = "#38ff9f"; # Dusk Moss
          orange = "#ffaf4d"; # Ember Glow
          pink = "#fb5bb6"; # Fading Rose
          purple = "#8a69f7"; # Vesper Violet
          red = "#fb5b66"; # Dusk Crimson
          yellow = "#fff952"; # Last Light Yellow
        };
      };

      mkColorGroup =
        p:
        {
          bg,
          bgAlt,
          fg ? p.foreground,
          onAccent ? false,
          # Dusk: warnings should use orange rather than neon yellow.
          neutral ? p.yellow,
        }:
        let
          text = if onAccent then p.onAccent else fg;
        in
        {
          BackgroundAlternate = bgAlt;
          BackgroundNormal = bg;
          DecorationFocus = p.green;
          DecorationHover = p.purple;
          ForegroundActive = if onAccent then text else p.purple;
          ForegroundInactive = if onAccent then text else p.comment;
          ForegroundLink = if onAccent then text else p.cyan;
          ForegroundNegative = if onAccent then text else p.red;
          ForegroundNeutral = if onAccent then text else neutral;
          ForegroundNormal = text;
          ForegroundPositive = if onAccent then text else p.green;
          ForegroundVisited = if onAccent then text else p.purple;
        };

      mkScheme =
        {
          colorScheme,
          name,
          palette,
          light ? false,
        }:
        let
          p = palette // {
            # Text drawn on the green accent: dark ink on Dusk, sunken grey
            # on the dark palettes.
            onAccent = if light then palette.foreground else palette.background;
            # Window/header/titlebar surface. Plain blue-grey `currentline`
            # from the upstream palette: purple is an accent here, never the
            # base. Do not tint this toward an accent to chase a styled
            # widget -- Oxygen's progress bar, for one, dilutes Window to
            # ~20-30% of a near-white mix, so tinting it 25% purple was
            # invisible there and lavendered every window and titlebar.
            chrome = palette.currentline;
          };
          neutral = if light then p.orange else p.yellow;
          group = args: mkColorGroup p (args // { inherit neutral; });
          # Complementary is the inverted set Plasma uses for lock/logout
          # and similar “other” surfaces. Light schemes get a dark panel.
          complementary =
            if light then
              group {
                bg = p.foreground;
                bgAlt = p.foreground;
                fg = p.background;
              }
            else
              group {
                bg = p.background;
                bgAlt = p.currentline;
              };
        in
        # Identity section names: Plasma's inactive header group is
        # `[Colors:Header][Inactive]`, and the default toINI escaper would
        # turn the brackets into `\[`.
        lib.generators.toINI { mkSectionName = section: section; } {
          "ColorEffects:Disabled" = {
            Color = p.currentline;
            ColorAmount = 0;
            ColorEffect = 0;
            ContrastAmount = "0.65";
            ContrastEffect = 1;
            IntensityAmount = "0.1";
            IntensityEffect = 2;
          };
          "ColorEffects:Inactive" = {
            ChangeSelectionColor = true;
            Color = p.overlay;
            ColorAmount = "0.025";
            ColorEffect = 2;
            ContrastAmount = "0.1";
            ContrastEffect = 2;
            Enable = false;
            IntensityAmount = 0;
            IntensityEffect = 0;
          };
          "Colors:Button" = group {
            bg = p.surface;
            bgAlt = p.overlay;
          };
          "Colors:Complementary" = complementary;
          "Colors:Header" = group {
            bg = p.chrome;
            bgAlt = p.background;
          };
          # toINI wraps the attr name in []; this becomes [Colors:Header][Inactive].
          "Colors:Header][Inactive" = group {
            bg = p.background;
            bgAlt = p.chrome;
          };
          "Colors:Selection" = group {
            bg = p.green;
            bgAlt = p.green;
            onAccent = true;
          };
          # `overlay` is the one non-blue entry in the ramp and by far the
          # lightest (luma 0.108 against Breeze Dark's 0.021), so it washes
          # tooltips out. Sit them on `surface` alongside buttons instead.
          "Colors:Tooltip" = group {
            bg = p.surface;
            bgAlt = p.currentline;
          };
          "Colors:View" = group {
            bg = p.background;
            bgAlt = p.currentline;
          };
          "Colors:Window" = group {
            bg = p.chrome;
            bgAlt = p.surface;
          };
          General = {
            ColorScheme = colorScheme;
            Name = name;
            accentActiveTitlebar = false;
            shadeSortColumn = true;
          };
          KDE = {
            contrast = 4;
          };
          WM = {
            activeBackground = p.chrome;
            activeBlend = p.foreground;
            activeForeground = p.foreground;
            inactiveBackground = p.background;
            inactiveBlend = p.comment;
            inactiveForeground = p.comment;
          };
        };

      schemes = {
        Eldritch = mkScheme {
          colorScheme = "Eldritch";
          name = "Eldritch";
          palette = palettes.cthulhu;
        };
        EldritchAbyss = mkScheme {
          colorScheme = "EldritchAbyss";
          name = "Eldritch Abyss";
          palette = palettes.abyss;
        };
        EldritchDusk = mkScheme {
          colorScheme = "EldritchDusk";
          name = "Eldritch Dusk";
          palette = palettes.dusk;
          light = true;
        };
      };

      eldritchAdw = pkgs.fetchFromGitHub {
        owner = "eldritch-theme";
        repo = "adw";
        rev = "3007f18ce7554634f6cb18ad40cdf7371a4ee058";
        hash = "sha256-/A2YvD1GyeF47oOQ2KkKibMooMsxO8NA4i0H+stdxBY=";
      };

      eldritchGtkCss = builtins.readFile "${eldritchAdw}/themes/eldritch-cthulhu.css";
    in
    {
      imports = [
        self.homeModules.linuxDesktopKwinThirds
        inputs.plasma-manager.homeModules.plasma-manager
      ];

      # Cthulhu is the default Eldritch palette and matches Ghostty.
      programs.plasma = {
        enable = true;
        workspace.colorScheme = "Eldritch";
        configFile.kdeglobals.General.accentColorFromColorScheme = true;
      };

      # GTK3 apps use adw-gtk3-dark; the Eldritch CSS overrides Adwaita
      # named colors for both GTK3 and GTK4/libadwaita.
      # https://github.com/eldritch-theme/adw
      gtk = {
        enable = true;
        colorScheme = "dark";
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        # adw-gtk3 has no GTK 2 theme.
        gtk2.enable = false;
        gtk3.extraCss = eldritchGtkCss;
        # Do not import adw-gtk3 as user CSS for GTK 4: libadwaita already
        # ships its own stylesheet, and a user-priority import stomps on app
        # styles. Named-color overrides in extraCss are the supported hook.
        gtk4.theme = null;
        gtk4.extraCss = eldritchGtkCss;
      };

      xdg.dataFile = lib.mapAttrs' (
        name: text:
        lib.nameValuePair "color-schemes/${name}.colors" {
          inherit text;
        }
      ) schemes;

      home.packages =
        (with pkgs.kdePackages; [
          akregator
          alligator
          ark # For extraction/compression in Dolphin.
          aurorae
          dolphin
          dolphin-plugins
          filelight
          gwenview
          kompare
          krdc
          ocean-sound-theme
          okular
          oxygen
          oxygen-icons
          oxygen-sounds
          plasma-thunderbolt
          spectacle
        ])
        ++ (with pkgs; [
          /**
            Plugins for Ark to support more archive formats.
          */
          p7zip
          unrar # unfreeRedistributable; allowUnfree is on in common/nixos.nix
          unzip
          zip
        ]);
    };
}
