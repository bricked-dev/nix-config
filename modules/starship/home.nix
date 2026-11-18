{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib.modules) mkIf mkMerge mkForce;
  inherit (config.lib.nushell) mkNushellInline;

  cfg = config.programs.starship;

  loadPreset = name: fromTOML (readFile "${pkgs.starship}/share/starship/presets/${name}.toml");
  plainTextSymbols = loadPreset "plain-text-symbols";
in {
  config = mkIf cfg.enable (mkMerge [
    {
      programs.starship.settings = mkMerge [
        plainTextSymbols

        {
          character.error_symbol = mkForce "[>](bold green)";
          format = mkForce "$all$line_break$character";

          status = mkForce {
            disabled = false;
            symbol = "failed ";
          };
        }
      ];
    }
    (mkIf cfg.enableNushellIntegration {
      programs.starship.settings.profiles.transient = "$character";
      programs.nushell.environmentVariables.TRANSIENT_PROMPT_COMMAND =
        mkNushellInline
        # nu
        ''
          {||
              (
                  # The initial value of `$env.CMD_DURATION_MS` is always `0823`, which is an official setting.
                  # See https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687.
                  let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
                  ^${cfg.package}/bin/starship prompt
                      --profile transient
                      --cmd-duration $cmd_duration
                      $"--status=($env.LAST_EXIT_CODE)"
                      --terminal-width (term size).columns
                      ...(
                          if (which "job list" | where type == built-in | is-not-empty) {
                              ["--jobs", (job list | length)]
                          } else {
                              []
                          }
                      )
              )
          }
        '';
    })
  ]);
}
