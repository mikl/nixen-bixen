{ inputs, ... }:
{
  flake.homeModules.greylineHomeConfig =
    { pkgs, ... }:
    {
      imports = [ inputs.greyline.homeManagerModules.default ];

      services.greyline = {
        enable = true;
        fontFamily = "Iosevka Etoile"; # resolved via fontconfig
        settings = {
          theme = "dark";
          format = "24h";
          twilight = {
            bands = true;
            darkness = "subtle";
          };
          home = {
            tz = "auto";
            column_highlight = true;
          }; # "auto" = system tz
          city = [
            {
              name = "Nørhå";
              lat = 56.899410237923206;
              lon = 8.44570407163216;
              tz = "Europe/Copenhagen";
            }
            {
              name = "Kuala Lumpur";
              lat = 3.14;
              lon = 101.69;
              tz = "Asia/Kuala_Lumpur";
            }
            {
              name = "London";
              lat = 51.51;
              lon = -0.13;
              tz = "Europe/London";
            }
            {
              name = "Moskva";
              lat = 55.755833;
              lon = 37.617778;
              tz = "Europe/Moscow";
            }
            {
              name = "New York";
              lat = 40.71;
              lon = -74.01;
              tz = "America/New_York";
            }
            {
              name = "Tokyo";
              lat = 35.68;
              lon = 139.69;
              tz = "Asia/Tokyo";
            }
          ];
        };
      };
    };
}
