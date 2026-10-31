# Evaluation fixture only; never deploy this configuration.
{
  imports = [
    ../../lib/imports.nix
    ./hardware.nix
  ];

  # Evaluate features without a bootloader or machine-specific user settings.
  boot.loader.grub.enable = false;

  modules = {
    dev.git.enable = true;
    networking.enable = true;
    services = {
      incus.enable = true;
      openssh.enable = true;
      ovn.enable = true;
    };
    shell.zsh.enable = true;
  };

  system.stateVersion = "26.05";
}
