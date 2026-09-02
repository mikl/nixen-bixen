/**
  Firefox. The 1Password extension is configured alongside the desktop app in
  the linuxDesktopOnePassword module, since one enterprise policy covers both
  Firefox and every PWA profile.
*/
{ ... }:
{
  flake.nixosModules.browsersFirefox =
    { ... }:
    {
      programs.firefox = {
        enable = true;

        # Gecko formats dates and times from the app locale, and Firefox is
        # packaged with the en-US langpack only -- so HTML date pickers come
        # out as m/d/y with an am/pm selector. This makes it format from
        # LC_TIME instead, without touching the UI language.
        #
        # Note the plural: intl.regional_prefs.use_os_locale (singular) is a
        # common misspelling, and since unknown prefs are accepted silently it
        # shows up as applied in about:policies while doing nothing at all.
        #
        # The policy lands in /etc/firefox/policies/policies.json, which the
        # PWAsForFirefox runtime reads as well, so it covers the PWAs too.
        policies.Preferences."intl.regional_prefs.use_os_locales" = {
          Value = true;
          Status = "default";
        };
      };
    };
}
