{
  description = "Raspberry Pi 5 Kiosk System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    comin.url = "github:nlewo/comin";
    sops-nix.url = "github:mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      nixos-raspberrypi,
      ...
    }@inputs:
    {
      nixosConfigurations.rpi-kiosk = nixos-raspberrypi.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/rpi-kiosk.nix
          sops-nix.nixosModules.sops
          nixos-raspberrypi.nixosModules.default
          nixos-raspberrypi.nixosModules.default
        ];
        specialArgs = { inherit nixos-raspberrypi; };
      };

      nixConfig = {
        extra-substituters = [
          "https://cache.nixos.org"
        ];
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
}
