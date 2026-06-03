{ ... }:
{
  flake.homeModules.neoVimNVF =
    { pkgs, ... }:
    {
      programs.nvf = {
        enable = true;
        settings = {
          vim = {
            filetree.neo-tree.enable = true;

            git.enable = true;

            languages = {
              enableFormat = true;
              enableTreesitter = true;

              nix.enable = true;
              nix.format.type = ["nixfmt"];
            };

            lsp = {
            enable = true;
          };

            options = {
              shiftwidth = 2;
              tabstop = 2;
            };

            telescope.enable = true;

            theme = {
              enable = true;
              name = "tokyonight";
              style = "night";
            };

            vimAlias = true;
          };
        };
      };
    };
}
