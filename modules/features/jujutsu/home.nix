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

      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            email = "mikkel@hoegh.org";
            name = "Mikkel T. Høgh";
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
