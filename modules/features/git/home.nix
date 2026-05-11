{ self, inputs, ... }:
{
  flake.homeModules.gitHomeConfig =
    { pkgs, ... }:
    {
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
      };

      programs.difftastic = {
        enable = true;
        options = {
          tab-width = 2;
        };
      };

      programs.git = {
        enable = true;
        attributes = [
          "*.css eol=lf diff=css"
          "*.md eol=lf diff=markdown"
          "*.php eol=lf diff=php"
          "*.py eol=lf diff=python"
          "*.ex eol=lf diff=elixir"
          "*.exs eol=lf diff=elixir"
          "mix.lock merge=binary"
        ];
        ignores = [
          "*.komodoproject"
          "*.orig"
          "*.py[co]"
          "*.swp"
          "*~"
          ".DS_Store"
          "._*"
          ".elixir-tools"
          ".elixir_ls"
          ".idea"
          ".sass-cache"
          ".svn"
          "npm-debug.log"
        ];
        settings = {
          alias = {
            br = "branch";
            st = "status";
            ci = "commit";
            co = "checkout";
            staged = "diff --cached";
            oneline = "log --pretty=oneline";
            llog = "log --date=local";
            changes = "diff --name-status -r";
            unadd = "update-index --force-remove";
          };
          color = {
            interactive = "auto";
            ui = "auto";
          };
          core = {
            autocrlf = "false";
            editor = "nvim";
            hooksPath = ".githooks";
            legacyheaders = "false";
            quotepath = "false";
          };
          format.numbered = "auto";
          delta.navigate = "true";
          fetch.prune = "true";
          github.user = "mikl";
          init.defaultBranch = "master";
          merge.conflictstyle = "zdiff3";
          mergetool = {
            keepBackup = "false";
            prompt = "false";
          };
          pull = {
            # Do fast-forward only merges on `git pull`
            rebase = "false";
            ff = "only";
          };
          push = {
            default = "simple";
            autoSetupRemote = "true";
          };
          rebase.autoStash = 1;
          repack.usedeltabaseoffset = "true";
          rerere.enabled = 1;
          user = {
            name = "Mikkel T. Hoegh";
            email = "mikkel@hoegh.org";
          };
        };
      };

      programs.lazygit = {
        enable = true;
        settings = {
          gui = {
            timeFormat = "_2. Jan 06";
            shortTimeFormat = "15:04";
            nerdFontsVersion = "3";
          };
          git = {
            pagers = [
              {
                pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'";
              }
              { externalDiffCommand = "difft --color=always"; }
            ];
            # Disable autofetch, only fetch manually.
            autoFetch = false;
            # Custom GPG handling since we rely on 1Password’s agent.
            overrideGpg = true;
          };
          # Disable self-update checks, since installation is managed by Nix.
          update.method = "never";
          os.editPreset = "nvim";
        };
      };
    };
}
