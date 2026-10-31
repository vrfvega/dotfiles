{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.incus;
in
{
  options.modules.services.incus = {
    enable = mkEnableOption "Incus";
  };

  config = mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = true;
    };
  };
}
