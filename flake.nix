{
  description = "Raspberry Pi 5 Kiosk System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
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
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system}.extend (
        final: prev: {
          comin = final.callPackage ./pkgs/comin { };
        }
      );
      ha-health-exporter = pkgs.callPackage ./pkgs/ha-health-exporter {};
      comin = pkgs.comin;
    in
    {
      packages.${system} = {
        ha-health-exporter = pkgs.callPackage ./pkgs/ha-health-exporter {};
        comin = pkgs.comin;
        inherit (pkgs) firefox-esr;
      };

      nixosConfigurations.rpi-kiosk = nixos-raspberrypi.lib.nixosSystem {
        system = system;
        modules = [
          ./hosts/rpi-kiosk.nix
          sops-nix.nixosModules.sops
          nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
          nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
          ./comin/comin.nix
        ];
        specialArgs = { inherit nixos-raspberrypi ha-health-exporter comin; };
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
