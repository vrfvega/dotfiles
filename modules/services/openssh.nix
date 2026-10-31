{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.services.openssh;
in
{
  options.modules.services.openssh = {
    enable = mkEnableOption "OpenSSH";
  };

  config = mkIf cfg.enable {
    services.openssh.enable = true;
  };
}
