{
  description = "Raspberry Pi 5 Kiosk System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:mic92/sops-nix";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    agenix.url = "github:ryantm/agenix";
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
      nixosConfigurations.rpi-kiosk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/rpi-kiosk.nix
        ];
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
