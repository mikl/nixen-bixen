{ ... }:
{
  flake.homeModules.neoVimNVF =
    { pkgs, ... }:
    {
      programs.nvf = {
        enable = true;
        settings = {
          vim = {
            binds.whichKey.enable = true;

            filetree.neo-tree.enable = true;

            git.enable = true;

            keymaps = [
              {
                key = "<leader>e";
                mode = "n";
                action = "<cmd>Neotree toggle<CR>";
                desc = "Toggle NeoTree";
              }
            ];

            languages = {
              enableFormat = true;
              enableTreesitter = true;

              bash.enable = true;
              css.enable = true;
              docker.enable = true;
              env.enable = true;
              html.enable = true;
              json.enable = true;
              json.format.type = [ "prettier" ];
              markdown.enable = true;
              nix.enable = true;
              nix.format.type = [ "nixfmt" ];
              toml.enable = true;
              typescript.enable = true;
              yaml.enable = true;
            };

            lsp = {
              enable = true;

              /**
                Let nil fetch missing flake inputs into the store on its own.

                Without this, opening any file in a flake whose inputs are not
                fully realised pops a "Some flake inputs are not available.
                Fetch them now?" prompt on startup.

                nvf's nil preset already tries to set this, but it writes it to
                `nil.nix.autoArchive`; nil actually reads
                `nil.nix.flake.autoArchive`, so the preset is a no-op.
              */
              servers.nil.settings.nil.nix.flake.autoArchive = true;
            };

            options = {
              clipboard = "unnamedplus"; # Use the system (Wayland) clipboard for y/p.
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
