{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.dev.git;
in
{
  options.modules.dev.git = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Git";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        config = {
          user = {
            name = "Victor Fonseca";
            email = "vrfvega@gmail.com";
          };
          pull.rebase = true;
          init.defaultBranch = "main";
        };
      };
    };
  };
}
