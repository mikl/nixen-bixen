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

              bash.enable = true;
              css.enable = true;
              docker.enable = true;
              env.enable = true;
              html.enable = true;
              json.enable = true;
              json.format.type = ["prettier"];
              markdown.enable = true;
              nix.enable = true;
              nix.format.type = ["nixfmt"];
              toml.enable = true;
              typescript.enable = true;
              yaml.enable = true;
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
