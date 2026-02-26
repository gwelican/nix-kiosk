# Minimal host configuration
{ config, pkgs, ... }: {
  sops.age.keyFile = ./secrets/age.key;
  networking.hostName = "rpi-kiosk";
  services.dbus.enable = true;
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/mmcblk0" ];
  };
  system.stateVersion = "24.11";
  comin.systemd.enable = true;
}

  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
  };