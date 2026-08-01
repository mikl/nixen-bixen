/**
  Common features for all homes.
*/
{ ... }:
{
  flake.homeModules.common =
    { pkgs, ... }:
    {
      # Prefer XDG directories for config and data to leave less junk in the home directory.
      home.preferXdgDirectories = true;

      home.packages = with pkgs; [
        git
        neovim
        nixfmt
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
      };

      # Set XDG folder env vars, since some apps don’t use them if they’re not
      # defined explicity.
      xdg.enable = true;
      xdg.localBinInPath = true;
    };
}
