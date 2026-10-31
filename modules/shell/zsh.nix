{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.shell.zsh;
in
{
  options.modules.shell.zsh = {
    enable = mkEnableOption "Zsh";
    default = mkOption {
      description = "Whether to set Zsh as the default shell for vrfvega";
      example = true;
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    users.users.vrfvega.shell = mkIf cfg.default pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "HIST_IGNORE_ALL_DUPS"
      ];
    };
  };
}
