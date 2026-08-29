/**
  AI coding agents feature.
*/
{ inputs, ... }:
{
  flake.homeModules.devAiHomeManager =
    { config, pkgs, ... }:
    let
      nixEnvironmentRule = ''
        # Environment

        Nix is available (flakes + the new CLI). A tool missing from PATH is
        never evidence the host lacks it.

        - One-off: `nix run nixpkgs#<pkg> -- <args>` (note the `--`).
        - Several tools, or an interactive session:
          `nix shell nixpkgs#<pkg1> nixpkgs#<pkg2> -c <cmd>`.

        Use this instead of skipping a check, or reporting a tool as
        unavailable. `python3` in particular is not on PATH — reach for
        `nix run` rather than working around it.

        Do not install packages persistently (`nix profile install`) or add
        them to a flake/home-manager config to satisfy a temporary need.
      '';

      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };

      # Kernel/LLVM-style trailer. Claude Code still injects Co-Authored-By
      # via its git prompt, so git-attribution.md repeats the same wording.
      # Grok also loads ~/.claude/rules, so each rule names its agent.
      attributionTrailer = name: "Assisted-by: ${name}";

      gitAttributionRule = name: ''
        # Git attribution

        You are ${name}. Use `${attributionTrailer name}` as the git trailer
        on commits and pull requests. Never add `Co-Authored-By`.
      '';

      claudeAttributionTrailer = attributionTrailer "Claude";

      # User-level Claude Code settings, shared across all machines.
      #
      # Managing this file declaratively means changes made from within
      # Claude Code (`/config`, `/output-style`) are reverted on the next
      # home-manager activation — adjust the settings here instead.
      claudeSettings = {
        outputStyle = "Concise";
        model = "opus[1m]";
        tui = "fullscreen";
        skipAutoPermissionPrompt = true;
        permissions.allow = [
          "Bash(nix run nixpkgs#*)"
          "Bash(nix shell nixpkgs#*)"
        ];
        attribution = {
          commit = claudeAttributionTrailer;
          pr = claudeAttributionTrailer;
          sessionUrl = false;
        };
      };
    in
    {

      home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;

      home.file.".claude/rules/environment.md".text = nixEnvironmentRule;
      home.file.".claude/rules/git-attribution.md".text = gitAttributionRule "Claude";
      home.file.".grok/rules/environment.md".text = nixEnvironmentRule;
      home.file.".grok/rules/git-attribution.md".text = gitAttributionRule "Grok";

      home.packages = [
        unstable.claude-code
        unstable.grok-build
      ];
    };

}
