/**
  Common features for all homes.
*/
{ ... }:
{
  flake.homeModules.common =
    { config, pkgs, ... }:
    {
      # Prefer XDG directories for config and data to leave less junk in the home directory.
      home.preferXdgDirectories = true;

      home.packages = with pkgs; [
        git
        libjxl # To re-encode pictures with cjxl
        q
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        VISUAL = "nvim";
        # Disable ads from npm packages.
        DISABLE_OPENCOLLECTIVE = 1;
        # Put Go’s compiler output inside the data path so it does not make a mess
        # in the home dir.
        GOPATH = "$HOME/.local/share/go";
        # RubyGems 3.2 and newer follow XDG by themselves, Bundler never learned
        # to, so point it at the right places by hand.
        BUNDLE_USER_CONFIG = "${config.xdg.configHome}/bundle";
        BUNDLE_USER_CACHE = "${config.xdg.cacheHome}/bundle";
        BUNDLE_USER_PLUGIN = "${config.xdg.dataHome}/bundle";
      };

      # Set XDG folder env vars, since some apps don’t use them if they’re not
      # defined explicity.
      xdg.enable = true;
      xdg.localBinInPath = true;
    };
}
