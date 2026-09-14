{ ... }:
{
  flake.homeModules.neoVimNVF =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      programs.nvf = {
        enable = true;
        settings = {
          vim = {
            binds.whichKey = {
              enable = true;

              /**
                Label the leader-menu groups that nothing else names, so they
                stop showing up as a bare "+N keymaps".

                nvf's own `binds.whichKey.register` takes a description and
                nothing else, so the entries go through which-key's `spec`
                instead, which accepts the full mapping spec — `group` (which
                gets the `+` prefix added for it) and `icon`. Each entry is
                `mkLuaInline` because the prefix is a positional field, which a
                Nix attrset cannot express.

                Icons are the ones which-key's own `icons.rules` already use
                for the matching leaf mappings, so a group and its contents
                look like they belong together.

                `<leader>f` (Telescope) and `<leader>h` (Gitsigns) are left
                alone; nvf labels those itself.
              */
              setupOpts.spec = map mkLuaInline [
                # git-conflict.nvim: co/ct/cb/c0 pick a side in a conflict.
                "{ '<leader>c', group = 'Git conflicts', icon = { icon = ' ', color = 'red' } }"

                # toggleterm's floating lazygit lives here.
                "{ '<leader>g', group = 'Git', icon = { icon = ' ', color = 'orange' } }"

                # The LSP binds, attached per-buffer by nvf's lsp module.
                "{ '<leader>l', group = 'LSP', icon = { icon = ' ', color = 'blue' } }"

                # fzf-lua and grug-far, see the keymaps below.
                "{ '<leader>s', group = 'Search and replace', icon = { icon = ' ', color = 'green' } }"

                # Gitsigns' toggles: blame and deleted-line preview.
                "{ '<leader>t', group = 'Toggle', icon = { icon = ' ', color = 'yellow' } }"
              ];
            };

            filetree.neo-tree.enable = true;

            git.enable = true;

            keymaps = [
              {
                key = "<leader>e";
                mode = "n";
                action = "<cmd>Neotree toggle<CR>";
                desc = "Toggle NeoTree";
              }

              /**
                fzf-lua and grug-far live under `<leader>s`; Telescope already
                owns `<leader>f` (see `vim.telescope.mappings`), and its grep is
                kept around for the cases where its previewer is nicer.

                nvf lazy-loads both plugins on their commands, so these must be
                `<cmd>`/`:` invocations rather than `require(...)` calls.
              */
              {
                key = "<leader>ss";
                mode = "n";
                action = "<cmd>FzfLua builtin<CR>";
                desc = "All pickers [fzf-lua]";
              }
              {
                key = "<leader>sg";
                mode = "n";
                action = "<cmd>FzfLua live_grep<CR>";
                desc = "Live grep, `-- <glob>` to filter [fzf-lua]";
              }
              {
                key = "<leader>sb";
                mode = "n";
                action = "<cmd>FzfLua lgrep_curbuf<CR>";
                desc = "Live grep current buffer [fzf-lua]";
              }
              {
                key = "<leader>sw";
                mode = "n";
                action = "<cmd>FzfLua grep_cword<CR>";
                desc = "Grep word under cursor [fzf-lua]";
              }
              {
                key = "<leader>sw";
                mode = "x";
                action = "<cmd>FzfLua grep_visual<CR>";
                desc = "Grep selection [fzf-lua]";
              }
              {
                key = "<leader>sr";
                mode = "n";
                action = "<cmd>FzfLua resume<CR>";
                desc = "Resume last picker [fzf-lua]";
              }

              /**
                Visual-mode `:` mappings auto-insert the `'<,'>` range, which is
                what tells grug-far to use the selection: `GrugFar` seeds the
                search field from it, `GrugFarWithin` confines the replace to
                those lines.
              */
              {
                key = "<leader>sR";
                mode = "n";
                action = "<cmd>GrugFar<CR>";
                desc = "Search and replace in project [grug-far]";
              }
              {
                key = "<leader>sR";
                mode = "x";
                action = ":GrugFar<CR>";
                desc = "Search and replace, seeded with selection [grug-far]";
              }
              {
                key = "<leader>sW";
                mode = "x";
                action = ":GrugFarWithin<CR>";
                desc = "Search and replace within selection [grug-far]";
              }
            ];

            /**
              fzf-lua does the matching in the real `fzf` binary rather than in
              Lua, so it stays responsive on large trees, and `live_grep`
              accepts `-- <glob>` in the prompt to narrow by path.

              Unlike the Telescope module, this one does not pull in its own
              search binaries, hence `extraPackages` below.
            */
            fzf-lua.enable = true;

            extraPackages = [
              pkgs.fd
              pkgs.ripgrep
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
              Not a picker: a scratch buffer holding every match across the
              project, edited in place and written back with `:w`.
            */
            utility.grug-far-nvim.enable = true;

            # Terminal in an overlay.
            terminal.toggleterm = {
              enable = true;
              lazygit.enable = true;
            };

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
