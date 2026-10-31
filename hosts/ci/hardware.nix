# Minimal evaluation placeholders; no real disks or bootloader.
{
  nixpkgs.hostPlatform = "x86_64-linux";

  fileSystems."/" = {
    device = "/dev/disk/by-label/ci-root";
    fsType = "ext4";
  };
}
