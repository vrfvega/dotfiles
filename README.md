# NixOS dotfiles

Organization inspired by [zakuciael/nixos-dotfiles](https://github.com/zakuciael/nixos-dotfiles).

- `flake.nix` exports the deployable `nixos` configuration and a `ci` evaluation fixture.
- `configuration.nix` holds machine settings, locale, users, packages, and feature selections.
- `hosts/ci/configuration.nix` independently selects modules for evaluation without importing the base configuration.
- `hosts/ci/hardware.nix` supplies generic hardware settings for CI; never deploy this fixture.
- `modules/` groups toggleable features under dev, hardware, networking, services, and shell.

Enable features with `modules.<category>.<feature>.enable = true;`; networking uses `modules.networking.enable`. `lib/imports.nix` automatically discovers regular `.nix` files recursively under `modules/`. Nested `default.nix` files are included; symbolic links are skipped. Keep supporting Nix expressions outside `modules/` unless they are NixOS modules. New module files must be added to Git before flake evaluation.

Feature modules use `with lib;`, a local `cfg = config.modules.<feature>;` binding, grouped `options`, and `config = mkIf cfg.enable`. Set `modules.shell.zsh.default = true` to select Zsh as vrfvega's login shell while the Zsh module is enabled. This option defaults to false; this machine explicitly enables it.

## Build on NixOS

The deployable configuration imports `/etc/nixos/hardware-configuration.nix` locally, keeping your machine's hardware settings outside Git. Deployment requires `--impure`. CI uses `hosts/ci/hardware.nix` instead and requires no local hardware file.

Add new files to Git before evaluating the flake:

```sh
git add flake.nix configuration.nix hosts lib modules README.md .github .gitignore
nix eval --raw --no-update-lock-file .#nixosConfigurations.ci.config.system.build.toplevel.drvPath
sudo nixos-rebuild dry-build --flake .#nixos --impure
sudo nixos-rebuild switch --flake .#nixos --impure
```

GitHub Actions evaluates the independent CI configuration on pushes and pull requests. It imports the same module library and explicitly enables features to exercise them; add new feature selections there when they need coverage. Its hardware fixture only supplies a platform and root filesystem. CI does not validate the base configuration, bootloader, actual disks, or default user shell, build packages, or boot the system. It targets the `ci` output directly because a whole-flake check would also evaluate the deployment output that needs your local hardware file. For a full build before activation, run `nixos-rebuild build --flake .#nixos --impure` on NixOS.

OVN remains an untested single-node draft; its one-time Incus setup command is documented in `modules/services/ovn.nix`.
