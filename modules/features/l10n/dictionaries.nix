{ ... }:
{
  flake.homeModules.dictionaries =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        aspellDicts.de
        aspellDicts.da
        aspellDicts.en
        aspellDicts.en-computers
        hunspellDicts.de_CH
        hunspellDicts.da_DK
        hunspellDicts.en_US
      ];
    };
}
