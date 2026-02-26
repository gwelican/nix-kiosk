# Minimal host configuration
{ config, pkgs, ... }: {
  sops.age.keyFile = ./secrets/age.key;
  networking.hostName = "rpi-kiosk";

  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/mmcblk0" ];
  };
  system.stateVersion = "24.11";
  services.xserver.enable = false;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland = true;
  services.xserver.desktopManager.sway.enable = true;
  programs.sway.enable = true;
  services.xserver.videoDrivers = ["vc4"];
  wayland.windowManager.sway.rotation = 90;
  comin.systemd.enable = true;
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
  };
}
