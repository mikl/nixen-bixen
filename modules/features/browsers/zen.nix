/**
  Zen Browser, a Firefox fork with its own tab and workspace UI.
*/
{ inputs, ... }:
{
  flake.homeModules.browsersZen =
    { ... }:
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = false;

        # Format dates and times from LC_TIME rather than from the en-US
        # langpack Zen ships -- see the browsersFirefox module for why the
        # pref name is plural.
        policies.Preferences."intl.regional_prefs.use_os_locales" = {
          Value = true;
          Status = "default";
        };
      };
    };
}
