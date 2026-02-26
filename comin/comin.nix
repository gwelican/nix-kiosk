# comin: GitOps pull-based provisioning tool
# https://github.com/avito-tech/comin

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.comin;
in

{
  options.services.comin = {
    enable = lib.mkEnableOption "comin GitOps sync";

    repository = lib.mkOption {
      type = lib.types.str;
      default = "git@github.com:user/rpi-kiosk-config.git";
      description = "Git repository URL to pull configurations from.";
    };

    branch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Git branch to track and sync from.";
    };

    pollingInterval = lib.mkOption {
      type = lib.types.str;
      default = "60s";
      description = "Interval between Git polling and sync attempts.";
    };

    workDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/comin";
      description = "Working directory for comin repository clone.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install comin package if needed (using system comin from nixpkgs)
    environment.systemPackages = [
      pkgs.comin
    ];

    # systemd service for comin polling
    systemd.services.comin = {
      description = "comin GitOps configuration sync";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.comin}/bin/comin sync --polling-interval ${cfg.pollingInterval} --git-url ${cfg.repository} --branch ${cfg.branch} --work-dir ${cfg.workDir}";
        Restart = "always";
        RestartSec = "5";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Prometheus scrape config for comin metrics
    services.prometheus.scrapeConfigs = [
      {
        job_name = "comin";
        static_configs = [
          {
            targets = [ "localhost:9091" ];
          }
        ];
        metrics_path = "/metrics";
      }
    ];
  };
}
