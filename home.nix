{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mikl";
  home.homeDirectory = "/Users/mikl";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.go-task
    pkgs.httpie
    pkgs.just
    pkgs.kamal
    pkgs.nixfmt
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mikl/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    # Replace ls with eza.
    ls = "eza";
    ll = "eza -l";
    la = "eza -lAh";
    l = "eza -CF";

    # Replace cat with bat.
    cat = "bat --plain";

    # NeoVim shortcuts.
    ni = "nvim";
    vi = "nvim";

    lg = "lazygit";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bat = {
    enable = true;
    config = {
      paging = "never";
    };
  };

  programs.btop.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.fastfetch.enable = true;

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

  programs.lazydocker.enable = true;
  programs.tealdeer.enable = true;
}
