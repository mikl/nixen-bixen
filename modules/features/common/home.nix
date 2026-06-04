/**
  Common features for all homes.
*/
{ ... }:
{
  flake.homeModules.common =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        git
        nixfmt
        q
      ];

      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        VISUAL = "nvim";
        # Disable ads from npm packages.
        DISABLE_OPENCOLLECTIVE = 1;
        # Set XDG folders explicitly, since some apps don’t use them as defaults.
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        # Put Go’s compiler output inside the data path so it does not make a mess
        # in the home dir.
        GOPATH = "$HOME/.local/share/go";
      };
    };
}
