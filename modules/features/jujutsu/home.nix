{ ... }:
{
  flake.homeModules.jujutsuHomeConfig =
    { lib, pkgs, ... }:
    {
      home.packages = with pkgs; [
        blazingjj
        gg-jj
        jjui
        lazyjj
      ];

      home.shellAliases = {
        lj = "lazyjj";
      };

      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            email = "mikkel@hoegh.org";
            name = "Mikkel T. Høgh";
          };

          # Drag the bookmark along when committing on top of it, so working
          # directly on master does not mean moving the bookmark by hand after
          # every commit. Only bookmarks sitting on the new commit's parent are
          # advanced, so bookmarks elsewhere in the graph are left alone.
          experimental-advance-branches = {
            enabled-branches = [ "glob:*" ];
            disabled-branches = [ ];
          };

          aliases = {
            # Pull the nearest bookmark behind the working copy up to the last
            # finished commit, for when the bookmark drifted anyway -- building
            # commits with `jj new`/`jj describe` does not advance it.
            tug = [
              "bookmark"
              "move"
              "--from"
              "heads(::@- & bookmarks())"
              "--to"
              "@-"
            ];
          };

          # Render diffs with delta, like lazygit does.
          merge-tools.delta = {
            program = lib.getExe pkgs.delta;
            diff-args = [
              "--dark"
              "--paging=never"
              "--line-numbers"
              # jj runs the tool without a tty, so delta would otherwise pad
              # decorations and backgrounds out to an assumed 80 columns.
              "--width=variable"
              # jj diffs two scratch directories, so strip those from the
              # file headers to leave the plain repository-relative paths.
              "--file-transformation=s@^(left|right)/@@"
              "$left"
              "$right"
            ];
            # delta exits 1 when the inputs differ, just like diff(1).
            diff-expected-exit-codes = [
              0
              1
            ];
          };

          # lazyjj takes its own settings from the jj config.
          lazyjj.diff-tool = "delta";
        };
      };
    };
}
