/**
  Starship prompt, themed with Eldritch (Cthulhu variant, powerline style).

  Upstream theme: https://github.com/eldritch-theme/starship

  The powerline separators and module glyphs need a Nerd Font in the
  terminal; without one the segment bar renders as tofu.
*/
{ ... }:
{
  flake.homeModules.starship =
    { lib, ... }:
    {
      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          aws.disabled = true;
          azure.disabled = true;
          cobol.disabled = true;
          status.disabled = false;

          palette = "eldritch_cthulhu";

          # Two lines: the status bar (git, toolchains, env, clock) sits on top,
          # and the identity/location bar plus the prompt character get a line
          # of their own so typing never starts halfway across the terminal.
          #
          # Neither line takes a left cap glyph. Powerline has nothing rounded
          # on one corner only, so every available cap - half-circle  or
          # diagonal / - leaves the stacked lines either pinched or notched
          # where they meet. Starting both bars flush at column 0 is the one
          # way to get a straight left edge.
          format = lib.concatStrings [
            "$git_branch"
            "$git_status"
            "[](fg:tertiary bg:quaternary)"
            "$c"
            "$rust"
            "$golang"
            "$nodejs"
            "$bun"
            "$php"
            "$java"
            "$kotlin"
            "$haskell"
            "$python"
            "[](fg:quaternary bg:quinary)"
            "$direnv"
            "$nix_shell"
            "$conda"
            "[](fg:quinary bg:senary)"
            "$time"
            "[ ](fg:senary)"
            "$cmd_duration"
            "$line_break"
            "$os"
            "$username"
            "$hostname"
            "[](bg:secondary fg:primary)"
            "$directory"
            "[](fg:secondary)"
            " "
            "$character"
          ];

          os = {
            disabled = false;
            style = "bg:primary fg:base";
            # Leading space so the logo sits at the same offset as the git
            # branch symbol on the line above, now that neither bar has a cap.
            format = "[ $symbol]($style)";
            symbols = {
              Windows = "";
              Ubuntu = "󰕈";
              SUSE = "";
              Raspbian = "󰐿";
              Mint = "󰣭";
              Macos = "󰀵";
              Manjaro = "";
              Linux = "󰌽";
              Gentoo = "󰣨";
              Fedora = "󰣛";
              Alpine = "";
              Amazon = "";
              Android = "";
              AOSC = "";
              Arch = "󰣇";
              Artix = "󰣇";
              CentOS = "";
              Debian = "󰣚";
              Redhat = "󱄛";
              RedHatEnterprise = "󱄛";
              NixOS = "󱄅";
            };
          };

          username = {
            show_always = true;
            style_user = "bg:primary fg:base";
            style_root = "bg:primary fg:base";
            format = "[ $user]($style)";
          };

          # Same segment as username so SSH sessions read as `user@host`.
          # ssh_only is Starship's default; local prompts stay username-only.
          hostname = {
            ssh_only = true;
            style = "bg:primary fg:base";
            format = "[@$hostname]($style)";
          };

          directory = {
            style = "bg:secondary fg:base";
            format = "[ $path ]($style)";
            truncation_length = 3;
            truncation_symbol = "…/";
            substitutions = {
              Documents = "󰈙 ";
              Downloads = " ";
              Music = "󰝚 ";
              Pictures = " ";
              Developer = "󰲋 ";
            };
          };

          git_branch = {
            symbol = "";
            style = "bg:tertiary";
            format = "[[ $symbol $branch ](fg:base bg:tertiary)]($style)";
          };

          git_status = {
            style = "bg:tertiary";
            format = "[[($all_status$ahead_behind )](fg:base bg:tertiary)]($style)";
          };

          nodejs = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          bun = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          c = {
            symbol = " ";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          golang = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          php = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          java = {
            symbol = " ";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          kotlin = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          haskell = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version) ](fg:base bg:quaternary)]($style)";
          };

          python = {
            symbol = "";
            style = "bg:quaternary";
            format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:base bg:quaternary)]($style)";
          };

          docker_context = {
            symbol = "";
            style = "bg:quinary";
            format = "[[ $symbol( $context) ](fg:base bg:quinary)]($style)";
          };

          conda = {
            symbol = "  ";
            style = "fg:base bg:quinary";
            format = "[$symbol$environment ]($style)";
            ignore_base = false;
          };

          time = {
            disabled = false;
            time_format = "%R";
            style = "bg:senary";
            format = "[[  $time ](fg:base bg:senary)]($style)";
          };

          line_break = {
            disabled = false;
          };

          character = {
            disabled = false;
            success_symbol = "[❯](bold fg:primary)";
            error_symbol = "[❯](bold fg:quaternary)";
            vimcmd_symbol = "[❮](bold fg:secondary)";
            vimcmd_replace_one_symbol = "[❮](bold fg:quaternary)";
            vimcmd_replace_symbol = "[❮](bold fg:quaternary)";
            vimcmd_visual_symbol = "[❮](bold fg:senary)";
          };

          cmd_duration = {
            show_milliseconds = true;
            format = " in $duration ";
            style = "bg:senary";
            disabled = false;
          };

          # Upstream renders this as "direnv loaded/allowed", which is a lot of
          # bar for a state that is almost always nominal. Icons instead: the
          # folder-cog is direnv itself, and the two state glyphs appear only
          # when something is off - dormant, needs `direnv allow`, or denied.
          direnv = {
            disabled = false;
            symbol = "󱁿";
            loaded_msg = "";
            unloaded_msg = " 󰒲";
            allowed_msg = "";
            not_allowed_msg = " 󰀨";
            denied_msg = " 󰅙";
            style = "bg:quinary";
            format = "[[ $symbol$loaded$allowed ](fg:base bg:quinary)]($style)";
          };

          # `heuristic` is what makes this fire for flake-era `nix develop` and
          # `nix shell`; without it the module only detects classic nix-shell.
          nix_shell = {
            heuristic = true;
            symbol = "󱄅 ";
            style = "bg:quinary";
            format = "[[ $symbol$state( \\($name\\)) ](fg:base bg:quinary)]($style)";
          };

          palettes = {
            eldritch_cthulhu = {
              primary = "#37f499";
              secondary = "#04d1f9";
              tertiary = "#a48cf2";
              quaternary = "#f16c75";
              quinary = "#f7c67f";
              senary = "#f1fc79";
              base = "#212337";
            };
            eldritch_abyss = {
              primary = "#2dcc82";
              secondary = "#0396b3";
              tertiary = "#8b75d9";
              quaternary = "#cc5860";
              quinary = "#d4a666";
              senary = "#ccd663";
              base = "#171928";
            };
            eldritch_dusk = {
              primary = "#38ff9f";
              secondary = "#0ad6ff";
              tertiary = "#8a69f7";
              quaternary = "#fb5b66";
              quinary = "#ffaf4d";
              senary = "#fff952";
              base = "#1e2029";
            };
          };
        };
      };
    };
}
