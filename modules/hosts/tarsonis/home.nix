/**
  Home manager config for Tarsonis. Just there to select which features we want.
*/
{ self, inputs, ... }:
{
  flake.homeModules.tarsonis =
    { lib, pkgs, ... }:
    {
      imports = [
        inputs.nvf.homeManagerModules.default
        self.homeModules.browsersPwas
        self.homeModules.browsersZen
        self.homeModules.common
        self.homeModules.devAiHomeManager
        self.homeModules.linuxDesktopBasis
        self.homeModules.linuxDesktopDevelop
        self.homeModules.linuxDesktopEmailClient
        self.homeModules.linuxDesktopKDE
        self.homeModules.linuxDesktopSyncthing
        self.homeModules.localdevHomeManager
        self.homeModules.neoVimNVF
      ];

      home.packages = with pkgs; [
        # Apple Studio Display brightness control.
        asdbctl
      ];

      # kscreenlocker 6.8.0 never shows its implicit fingerprint prompt: it only
      # flags fingerprint as usable when availability *changes*, which a working
      # reader never does. Listing it as an explicit authenticator makes it
      # selectable on the lock screen instead. Drop once a release carries
      # upstream commit 0cf75b9 ("pamauthenticators: refactor fingerprint
      # detection"), which only exists on the work/sitter/fingers branch.
      programs.plasma.configFile.kscreenlockerrc.Authenticators.Fingerprint = true;

      # Mark bulky, re-creatable data as cache so the Restic backup skips it
      # (it runs with --exclude-caches). tmpfiles recreates a tag if an app
      # wipes its directory, and the d lines keep it from failing when the
      # app has not created the directory yet.
      systemd.user.tmpfiles.rules =
        lib.concatMap
          (dir: [
            "d %h/${dir} - - - -"
            "f %h/${dir}/CACHEDIR.TAG - - - - Signature: 8a477f597d28d172789f06886806bc55"
          ])
          [
            # KDE's file search index.
            ".local/share/baloo"
            # Proton Mail Bridge's copy of the mailbox, re-synced from the server.
            ".local/share/protonmail/bridge-v3"
            ".local/share/pnpm/store"
            # Installed games and compiled shaders. Not compatdata, which
            # holds saves for games without Steam Cloud.
            ".local/share/Steam/steamapps/common"
            ".local/share/Steam/steamapps/shadercache"
            ".local/share/Trash"
          ];

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.
    };
}
