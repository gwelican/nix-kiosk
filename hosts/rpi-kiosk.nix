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
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };

  boot.loader.grub.enable = false;

  system.stateVersion = "24.11";
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
  systemd.services.ha-health-exporter = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    requires = [ "homeassistant.service" ];
    after = [ "homeassistant.service" ];
    serviceConfig = {
      ExecStart = "${ha-health-exporter}/bin/ha-health-exporter";
      Restart = "always";
      RestartSec = "5";
    };
  };
  services.prometheus = {
    enable = true;
    port = 9090;
    retentionTime = "15d";
    exporters = {
      node.enable = true;
    };
    scrapeConfigs = [
      {
        job_name = "node_exporter";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
          }
        ];
      }
      {
        job_name = "firefox_metrics";
        static_configs = [
          {
            targets = [ "localhost:9101" ];
          }
        ];
      }
      {
        job_name = "ha_health_exporter";
        static_configs = [
          {
            targets = [ "localhost:9102" ];
          }
        ];
      }
    ];
    ruleFiles = [ ../prometheus/rules/alerts.yml ];
  };
  services.grafana = {
    enable = true;
    port = 3000;
    settings = {
      server = {
        root_url = "%(protocol)s://%(domain)s:%(http_port)s/";
        serve_from_sub_path = true;
      };
    };
  };

  # Copy Grafana dashboards to the data directory
  environment.etc = {
    "grafana/dashboards/system-metrics.json".source = ../grafana/dashboards/system-metrics.json;
    "grafana/dashboards/firefox-health.json".source = ../grafana/dashboards/firefox-health.json;
    "grafana/dashboards/ha-connectivity.json".source = ../grafana/dashboards/ha-connectivity.json;
  };

  # GitOps configuration sync via comin
  imports = [
    ../comin/comin.nix
  ];

  services.comin.enable = true;
  services.comin.repository = "git@github.com:user/rpi-kiosk-config.git";
  services.comin.branch = "main";
  services.comin.pollingInterval = "60s";
}

