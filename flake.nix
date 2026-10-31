{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        /etc/nixos/hardware-configuration.nix
      ];
    };

    # Evaluation fixture only; never deploy this configuration.
    nixosConfigurations.ci = nixpkgs.lib.nixosSystem {
      modules = [
        ./hosts/ci/configuration.nix
      ];
    };
  };
}
