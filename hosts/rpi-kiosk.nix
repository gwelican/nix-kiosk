# Minimal host configuration
{ config, pkgs, ... }: {
  sops.age.keyFile = ./secrets/age.key;
  networking.hostName = "rpi-kiosk";
  services.dbus.enable = true;
  hardware.raspberry-pi."5".base = true;
  hardware.raspberry-pi."5".page-size-16k = true;
  hardware.raspberry-pi."5".display-vc4 = true;
  hardware.raspberry-pi."5".boot.loader = true;
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
  comin.systemd.enable = true;
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
  };
}
