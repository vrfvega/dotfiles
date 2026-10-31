{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.networking;
in
{
  options.modules.networking = {
    enable = mkEnableOption "NetworkManager and nftables";
  };

  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;
    networking.nftables.enable = true;
    networking.nftables.flushRuleset = false;
  };
}
