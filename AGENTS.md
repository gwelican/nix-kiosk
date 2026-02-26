# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-26
**Commit:** e2b98d2
**Branch:** master

## OVERVIEW

NixOS flake-based Raspberry Pi 5 kiosk system running Firefox in kiosk mode, displaying HomeAssistant dashboard with Sway compositor, comin GitOps sync, and Prometheus/Grafana monitoring.

## STRUCTURE

```
./
├── flake.nix          # NixOS flake entry: inputs/outputs, rpi-kiosk config
├── hosts/
│   └── rpi-kiosk.nix  # NixOS host config: Sway, Firefox, monitoring
├── pkgs/              # Custom package definitions
│   ├── comin/         # GitOps tool (Rust, v0.6.1)
│   └── ha-health-exporter/ # HomeAssistant health exporter (Python)
├── comin/
│   └── comin.nix      # comin NixOS module (GitOps integration)
├── secrets/           # SOPS age encryption keys + encrypted WiFi
├── deploy/            # Deployment scripts + documentation
├── prometheus/        # Prometheus config + alerting rules
└── grafana/           # Grafana config + dashboards
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Modify system config | `hosts/rpi-kiosk.nix` | All NixOS options |
| Add custom package | `pkgs/<name>/default.nix` | Use `rustPlatform` or `stdenv.mkDerivation` |
| Configure GitOps | `comin/comin.nix` | comin module options |
| Add alerting rule | `prometheus/rules/alerts.yml` | Prometheus alerting |
| Add Grafana dashboard | `grafana/dashboards/<name>.json` | Dashboard JSON |
| Update secrets | `secrets/age.key` + `secrets/<name>.age` | SOPS age encryption |

## CODE MAP

| Symbol | Type | Location | Refs | Role |
|--------|------|----------|------|------|
| `rpi-kiosk` | nixosConfig | `flake.nix:35` | - | Main NixOS system |
| `comin` | package | `pkgs/comin/` | 2 | GitOps sync tool |
| `ha-health-exporter` | package | `pkgs/ha-health-exporter/` | 1 | HA API exporter |
| `firefox-kiosk` | systemd | `hosts/rpi-kiosk.nix:60` | - | Firefox auto-recovery |
| `comin` | systemd | `comin/comin.nix:56` | 1 | GitOps polling |

## CONVENTIONS

- **flake.nix**: Use `builtins` for attribute access, `pkgs` for packages
- **hosts/**: NixOS module style with `{ config, pkgs, ... }` args
- **pkgs/**: Standard `default.nix` with `rustPlatform.buildRustPackage` or `stdenv.mkDerivation`
- **imports**: Relative paths (`../`, `./`) always, never absolute
- **SOPS**: `age` encryption only, keys in `secrets/age.key`
- **systemd**: `Restart=always` for kiosk services, `OOMScoreAdjust` for Firefox

## ANTI-PATTERNS (THIS PROJECT)

- ❌ Using `sdImage` instead of `system.build.images.sd-card` for RPi5 images
- ❌ `Type=oneshot` with `Restart=always` (use `Type=simple` for long-running services)
- ❌ Hardcoded paths (always use relative imports)
- ❌ `services.grafana.port` (deprecated, use `services.grafana.settings.server.http_port`)
- ❌ `bootloader = "kernelboot"` (deprecated, migrate to `kernel`)

## UNIQUE STYLES

- **comin module**: Custom NixOS module at flake root (not in `hosts/` or `modules/`)
- **Monitoring config**: Standalone directories (`prometheus/`, `grafana/`) referenced via `environment.etc`
- **Cross-directory imports**: `../` used frequently for Grafana dashboards, Prometheus rules
- **SpecialArgs**: `ha-health-exporter` and `comin` passed via `specialArgs` to host config

## COMMANDS

```bash
# Build NixOS system
nix build .#nixosConfigurations.rpi-kiosk.config.system.build.toplevel

# Build SD card image
nix build .#nixosConfigurations.rpi-kiosk.config.system.build.images.sd-card

# Validate flake
nix flake show
nix flake check

# Decrypt WiFi secrets (local testing)
sops -d secrets/wifi.age > secrets/wifi.yaml

# Deploy to RPi5
dd if=result/sd-image-aarch64-linux.img of=/dev/sdX bs=4M status=progress conv=fsync
```

## NOTES

- **RPi5 SD card path**: `system.build.images.sd-card` (NOT `sdImage`)
- **Cross-compilation**: Builds require `aarch64-linux` target, cannot build on x86_64
- **comin polling**: 60s interval by default, syncs from Git repository
- **Firefox kiosk**: `DisableAppUpdate=true`, `Fullscreen=true`, memory limits set
- **SOPS age**: Keys stored unencrypted in repo (age encryption for secrets)
- **Monitoring**: Prometheus scrapes node_exporter (9100), firefox_metrics (9101), ha_health_exporter (9102)