{ pkgs, ... }:
{
  home.username = "mikl";
  home.homeDirectory = "/Users/mikl";
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.go-task
    pkgs.httpie
    pkgs.just
    pkgs.kamal
    pkgs.nixfmt
  ];

  home.shellAliases = {
    ls = "eza";
    ll = "eza -l";
    la = "eza -lAh";
    l = "eza -CF";
    cat = "bat --plain";
    ni = "nvim";
    vi = "nvim";
    lg = "lazygit";
  };

  programs.home-manager.enable = true;

  programs.bat = {
    enable = true;
    config.paging = "never";
  };

  programs.btop.enable = true;
  programs.fastfetch.enable = true;
  programs.lazydocker.enable = true;
  programs.tealdeer.enable = true;
}
