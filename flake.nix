{
  description = "Raspberry Pi 5 Kiosk System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    sops-nix.url = "github:mic92/sops-nix";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      nixos-raspberrypi,
      comin,
      ...
    }@inputs:
    let
    in
    {

      nixosConfigurations.rpi-kiosk = nixos-raspberrypi.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/rpi-kiosk.nix
          sops-nix.nixosModules.sops
          nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
          nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
          comin.nixosModules.comin
          ({
            services.comin = {
              enable = true;
              remotes = [
                {
                  name = "origin";
                  url = "https://github.com/gwelican/nix-kiosk.git";
                  branches.main.name = "master";
                }
              ];
            };
          })
        ];
        specialArgs = { inherit nixos-raspberrypi comin; };
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
