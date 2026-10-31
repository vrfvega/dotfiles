{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.hardware.bootloader;
in
{
  options.modules.hardware.bootloader = {
    enable = mkEnableOption "systemd-boot";
  };

  config = mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
