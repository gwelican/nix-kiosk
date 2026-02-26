{
  config,
  pkgs,
  ha-health-exporter,
  ...
}:
{
  sops.age.keyFile = ./secrets/age.key;
  networking.hostName = "rpi-kiosk";
  services.dbus.enable = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };
  swapDevices = [ ];

  boot.loader.grub.enable = false;

  system.stateVersion = "26.05";
  services.xserver.enable = true;
  programs.sway.enable = true;

  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
  };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;
    policies = {
      StartPage = "https://homeassistant.local:8123";
      Fullscreen = true;
      DisablePromptOnShutdown = true;
      DisablePocket = true;
      DisableFeedback = true;
      DisableTelemetry = true;
      DisableAppUpdate = true;
      Preferences = {
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 51200;
        "browser.cache.check_doc_frequency" = false;
      };
    };
  };
  hardware.acpilight.enable = true;
  services.logind.settings = {
    Login.HandleLidSwitch = "ignore";
    Login.HandlePowerKey = "ignore";
  };
  services.journald = {
    rateLimitInterval = "30s";
    rateLimitBurst = 1000;
    extraConfig = ''
      SystemMaxUse=500M
      SystemKeepFree=200M
      SystemMaxFileSize=32M
    '';
  };
  systemd.services.firefox-kiosk = {
    enable = true;
    serviceConfig = {
      OOMScoreAdjust = -500;
      MemoryAccounting = true;
      MemoryHigh = "1.5G";
    };
  };
}
