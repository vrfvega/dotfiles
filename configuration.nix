{ pkgs, ... }:

{
  imports = [
    ./lib/imports.nix
  ];

  networking.hostName = "nixos";
  networking.firewall.allowedTCPPorts = [ 53 67 8443 ];
  networking.firewall.allowedUDPPorts = [ 53 67 ];

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.vrfvega = {
    isNormalUser = true;
    description = "Victor Fonseca";
    extraGroups = [ "wheel" "incus-admin" ];
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    nil
    git
    tealdeer
    bat
  ];

  environment.variables = {
    TERM = "xterm-256color";
  };

  modules = {
    dev.git.enable = true;
    hardware.bootloader.enable = true;
    networking.enable = true;
    services = {
      incus.enable = true;
      openssh.enable = true;
      ovn.enable = true;
    };
    shell.zsh = {
      enable = true;
      default = true;
    };
  };

  # Preserve the version from this machine's initial installation.
  system.stateVersion = "26.05";
}
