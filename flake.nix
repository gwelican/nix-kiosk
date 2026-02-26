{
  description = "Raspberry Pi 5 Kiosk System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    comin.url = "github:nlewo/comin";
    sops-nix.url = "github:mic92/sops-nix";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-raspberrypi,
      comin,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations.rpi-kiosk = nixos-raspberrypi.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit nixos-raspberrypi; };
        modules = [
          # Base RPi5 configuration
          {
            hardware.raspberry-pi."5".base = true;
            hardware.raspberry-pi."5".page-size-16k = true;
            hardware.raspberry-pi."5".display-vc4 = true;
          }

          # NixOS configuration
          {
            networking.hostName = "rpi-kiosk";
            services.xserver.enable = true;
            services.displayManager.gdm.enable = true;
            services.desktopManager.plasma6.enable = true;

            users.users.kiosk = {
              isNormalUser = true;
              description = "Kiosk User";
              extraGroups = [
                "wheel"
                "video"
                "dialout"
              ];
              shell = "/bin/bash";
            };

            services.openssh.enable = true;
            services.dbus.enable = true;
            system.stateVersion = "24.11";
          }

          # SOPS configuration
          sops-nix.nixosModules.sops
        ];
      };

      nixConfig = {
        extra-substituters = [
          "https://cache.nixos.org"
          "https://nixos-raspberrypi.cachix.org"
        ];
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nixos-raspberrypi.cachix.org-1:5RHR2/YKH9I462N8Qy15eMK1VJDawcBhZ4oVJ2mZRM0="
        ];
      };
    };
}
