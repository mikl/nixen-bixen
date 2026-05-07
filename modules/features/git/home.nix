{ self, inputs, ... }:
{
  flake.homeModules.gitHomeConfig =
    { pkgs, ... }:
    {
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
      };

      programs.git = {
        enable = true;
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
            pager = "delta";
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
    };
}
