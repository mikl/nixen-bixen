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

            /**
              Eldritch is not one of nvf's `supportedThemes`, so `vim.theme.name`
              (an enum over that list) cannot select it. Adding the plugin
              ourselves and setting the colorscheme by hand is all the theme
              module does anyway, so nothing is lost by bypassing it.
            */
            theme.enable = false;

            extraPlugins.eldritch = {
              package = pkgs.vimPlugins.eldritch-nvim;
              setup = ''
                require("eldritch").setup({
                  transparent = true,
                  terminal_colors = true,
                  styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    sidebars = "dark",
                    floats = "dark",
                  },
                  dim_inactive = false,
                  lualine_bold = true,

                  -- Plain strings default to yellow (#f1fc79), which shouts.
                  -- Halfway between the two foregrounds instead: `fg` (#ebfafa,
                  -- Lighthouse White) is indistinguishable from ordinary code,
                  -- `fg_dark` (#ABB4DA) recedes too far. The midpoint lands on
                  -- #cbd7ea, and blending keeps it correct in the darker
                  -- palettes, whose foregrounds differ.
                  --
                  -- Only `String` is touched; `@string` links to it, while the
                  -- specialised groups (@string.documentation, .html, .regexp,
                  -- .escape) keep their own colours.
                  on_highlights = function(highlights, colors)
                    local blend = require("eldritch.util").blend
                    highlights.String = { fg = blend(colors.fg, colors.fg_dark, 0.5) }
                  end,
                })

                -- Variants: "eldritch", "eldritch-dark", "eldritch-minimal".
                vim.cmd.colorscheme("eldritch")
              '';
            };

            vimAlias = true;
          };
        };
      };
    };
}
