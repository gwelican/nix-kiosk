{
  config,
  pkgs,
  lib,
  specialArgs,
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

    testBranch = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Testing branch to sync from (optional). If set, comin syncs from this branch instead of the main branch.";
    };

    rollbackVersion = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Specific version/commit to rollback to (optional). If set, comin syncs to this specific version instead of the branch head.";
    };
  };

  config = lib.mkIf cfg.enable {
    # systemd service for comin polling
    systemd.services.comin = {
      description = "comin GitOps configuration sync";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          "${specialArgs.comin}/bin/comin sync --polling-interval ${cfg.pollingInterval} --git-url ${cfg.repository} --branch ${
            if cfg.testBranch != null then cfg.testBranch else cfg.branch
          } --work-dir ${cfg.workDir}"
          + (if cfg.rollbackVersion != null then " --rollback-version ${cfg.rollbackVersion}" else "");
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
