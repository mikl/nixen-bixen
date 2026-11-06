/**
  Enterprise policies for the Chromium-based browsers (Chromium, Brave and
  Vivaldi). This does not install any of them; the packages come from the
  linux-desktop feature modules.
*/
{ ... }:
{
  flake.nixosModules.browsersChromium =
    { lib, ... }:
    let
      policies = {
        # No "make this your default browser" prompt. This also greys out the
        # "Make default" button in the browser's own settings; the default
        # browser is chosen in the desktop settings instead.
        DefaultBrowserSettingEnabled = false;
      };
    in
    {
      # Writes managed policies to /etc/chromium (Chromium, and Brave Origin
      # reads it as well), /etc/opt/chrome and /etc/brave. It does not install
      # a browser.
      programs.chromium = {
        enable = true;
        extraOpts = policies;
      };

      # Vivaldi reads /etc/vivaldi/policies only, which the nixpkgs module
      # does not cover.
      environment.etc."vivaldi/policies/managed/extra.json".text = builtins.toJSON policies;
    };
}
