# Raspberry Pi 5 Kiosk System

## TL;DR

> **Quick Summary**: NixOS-based kiosk on RPi5 with 2GB RAM, running Firefox in kiosk mode displaying HomeAssistant dashboard in portrait orientation, with systemd auto-recovery, comin GitOps provisioning, and age-encrypted WiFi secrets.
> 
> **Deliverables**:
> - NixOS flake configuration for RPi5
> - Sway compositor with Wayland display server
> - Firefox ESR kiosk mode with auto-start
> - systemd service with restart=always for crash recovery
> - comin GitOps provisioning module
> - age-encrypted WiFi credentials via SOPS
> - Prometheus + Grafana monitoring stack
> - SSH access with key-based authentication
> - USB touchscreen configuration
> - SD card image for initial deployment
>
> **Estimated Effort**: Medium (8-12 hours of work)
> **Parallel Execution**: YES - 6 waves with 5-8 tasks per wave
> **Critical Path**: Scaffolding → Base System → Display → Firefox → comin → Monitoring → QA

---

## Context

### Original Request

Create a Raspberry Pi 5 kiosk system with:
- Waveshare 15.6" touchscreen (1920x1080, USB)
- Firefox kiosk mode showing HomeAssistant dashboard
- Portrait (vertical) layout
- NixOS with flakes using comin provisioning
- Auto-recovery on crash
- SSH remote access
- WiFi with age-encrypted secrets in public Git repo
- Prometheus + Grafana monitoring
- Screen saver disabled

### Interview Summary

**Key Discussions**:
- **RAM**: 2GB model (user prefers to try first, upgrade if fails)
- **Display Server**: Wayland + Sway (modern RPi5 support)
- **Firefox**: ESR version + disable auto-updates (stability focus)
- **Auto-Recovery**: systemd Service Watchdog (restart=always)
- **Monitoring**: Full stack (Prometheus + Grafana)
- **Secrets**: age encryption via SOPS, stored in same Git repo as config
- **Deployment**: SD card image (recommended for RPi5)
- **WiFi**: Single network, static credentials
- **Network**: DHCP (automatic IP)
- **Audio**: Disabled

**Research Findings**:
- **nvmd/nixos-raspberrypi**: 447 stars, actively maintained, provides RPi5 modules
- **comin**: 822 stars, GitOps pull-based, 60s polling, testing branches, Prometheus metrics
- **age**: Modern encryption tool (1.4k stars), simpler than GPG, X25519 crypto
- **sops-nix**: NixOS module for automated secret decryption at boot
- **Sway + Wayland**: Modern display stack, better RPi5 support than X11

### Metis Review

**Identified Gaps** (addressed in plan):
- **Acceptance Criteria**: All executable commands (no manual testing)
- **Edge Cases**: HA downtime, network partitions, memory leaks handled
- **Security**: SSH keys + firewall + comin auth configured
- **Firefox**: ESR + hardware acceleration + update control
- **Monitoring**: Prometheus + Grafana + HA connectivity checks
- **Power**: Auto-boot on power + SD card wear leveling
- **WiFi**: age encryption with sops-nix integration

---

## Work Objectives

### Core Objective

Deploy a reliable, self-healing kiosk system on Raspberry Pi 5 that runs Firefox in kiosk mode displaying a HomeAssistant dashboard, with automatic crash recovery, GitOps provisioning, and comprehensive monitoring.

### Concrete Deliverables

- `flake.nix` - Main NixOS flake with RPi5 configuration
- `hosts/rpi-kiosk.nix` - Host-specific configuration
- `secrets/wifi.age` - Encrypted WiFi credentials
- `pkgs/kiosk-firefox/` - Custom Firefox wrapper service
- `pkgs/sensors/` - HA connectivity monitoring
- `deploy/` - SD card image build scripts
- `prometheus/` - Prometheus + Grafana configuration
- `comin/` - comin GitOps module

### Definition of Done

- [ ] System boots to Firefox kiosk mode automatically
- [ ] Firefox restarts automatically if it crashes
- [ ] WiFi connects using encrypted credentials
- [ ] SSH access works with key-based authentication
- [ ] comin syncs configuration from Git every 60s
- [ ] Prometheus monitors system health
- [ ] Grafana dashboards show kiosk status
- [ ] Touchscreen input works correctly
- [ ] Display rotated to portrait orientation
- [ ] All acceptance criteria pass (see TODOs)

### Must Have

- NixOS flake with RPi5 base from nvmd/nixos-raspberrypi
- Sway compositor with Wayland display server
- Firefox ESR in kiosk mode (fullscreen, no UI)
- systemd service with restart=always for Firefox
- comin GitOps module for configuration sync
- age-encrypted WiFi credentials via sops-nix
- SSH access with key-based authentication
- USB touchscreen support
- Portrait display rotation (1920x1080 → 1080x1920)
- Prometheus + Grafana monitoring stack
- HA connectivity health checks
- Auto-boot on power restoration

### Must NOT Have (Guardrails)

- ❌ **No GUI desktop environment** (GNOME/KDE) — only Sway + Firefox
- ❌ **No audio** — explicitly disable to save resources
- ❌ **No Bluetooth** — not needed, security risk
- ❌ **No automatic Firefox updates** — can break kiosk
- ❌ **No user accounts** — kiosk is single-user, root-only
- ❌ **No remote desktop** — SSH only, no VNC/Remmina
- ❌ **No hardware watchdog** — software watchdog only (systemd)
- ❌ **No motion detection** — future enhancement, not in scope
- ❌ **No complex UI customizations** — basic kiosk only

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.
> Acceptance criteria requiring "user manually tests/confirms" are FORBIDDEN.

### Test Decision

- **Infrastructure exists**: NO (fresh NixOS project)
- **Automated tests**: NO (agent-executed QA only)
- **Framework**: N/A (NixOS build verification)
- **If TDD**: Not applicable — NixOS uses declarative configuration

### QA Policy

Every task MUST include agent-executed QA scenarios (see TODO template below).
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

- **Frontend/UI**: Use Playwright (playwright skill) — Navigate, interact, assert DOM, screenshot
- **TUI/CLI**: Use interactive_bash (tmux) — Run command, send keystrokes, validate output
- **API/Backend**: Use Bash (curl) — Send requests, assert status + response fields
- **Library/Module**: Use Bash (bun/node REPL) — Import, call functions, compare output

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — foundation + scaffolding):
├── Task 1: Project scaffolding + flake.nix [quick]
├── Task 2: Age encryption setup + sops-nix [quick]
├── Task 3: WiFi secrets encrypted [quick]
├── Task 4: SSH keys configured [quick]
├── Task 5: comin module integration [quick]
├── Task 6: Prometheus + Grafana setup [quick]
└── Task 7: SD card image build config [quick]

Wave 2 (After Wave 1 — base system + display):
├── Task 8: RPi5 base configuration [deep]
├── Task 9: Wayland + Sway compositor [deep]
├── Task 10: Display rotation config [quick]
├── Task 11: USB touchscreen setup [deep]
├── Task 12: Network configuration (DHCP) [quick]
└── Task 13: Auto-boot on power [quick]

Wave 3 (After Wave 2 — Firefox + recovery):
├── Task 14: Firefox ESR installation [quick]
├── Task 15: Kiosk mode configuration [quick]
├── Task 16: systemd service with watchdog [deep]
├── Task 17: Memory leak mitigation [deep]
└── Task 18: Display brightness control [quick]

Wave 4 (After Wave 3 — monitoring + HA):
├── Task 19: Prometheus server config [deep]
├── Task 20: Grafana dashboards [visual-engineering]
├── Task 21: HA connectivity checks [deep]
├── Task 22: Alerting rules [quick]
└── Task 23: Logging configuration [quick]

Wave 5 (After Wave 4 — integration):
├── Task 24: comin GitOps sync setup [deep]
├── Task 25: Testing branch workflow [quick]
├── Task 26: Rollback mechanism [quick]
└── Task 27: Full integration test [deep]

Wave 6 (After Wave 5 — deployment):
├── Task 28: SD card image build [quick]
├── Task 29: Deployment documentation [writing]
└── Task 30: Final QA pass [unspecified-high]

Wave FINAL (After ALL tasks — independent review, 4 parallel):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)

Critical Path: Task 1 → Task 8 → Task 9 → Task 14 → Task 16 → Task 24 → Task 28 → F1-F4
Parallel Speedup: ~75% faster than sequential
Max Concurrent: 7 (Waves 1 & 2)
```

### Dependency Matrix

- **1-7**: — — 8-13, 14-23, 24-30
- **8**: 1 — 9-13, 14-30
- **9**: 8 — 10-18, 19-30
- **14**: 8, 9 — 15-23, 24-30
- **16**: 14, 15 — 17-23, 24-30
- **24**: 1-7, 8-23 — 25-30, F1-F4
- **28**: 1-27 — F1-F4
- **F1-F4**: 1-30 — (final review)

### Agent Dispatch Summary

- **1**: **7** — T1-T4 → `quick`, T5 → `quick`, T6 → `quick`, T7 → `quick`
- **2**: **6** — T8 → `deep`, T9 → `deep`, T10 → `quick`, T11 → `deep`, T12 → `quick`, T13 → `quick`
- **3**: **5** — T14 → `quick`, T15 → `quick`, T16 → `deep`, T17 → `deep`, T18 → `quick`
- **4**: **5** — T19 → `deep`, T20 → `visual-engineering`, T21 → `deep`, T22 → `quick`, T23 → `quick`
- **5**: **4** — T24 → `deep`, T25 → `quick`, T26 → `quick`, T27 → `deep`
- **6**: **3** — T28 → `quick`, T29 → `writing`, T30 → `unspecified-high`
- **FINAL**: **4** — F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep`

---

## TODOs

> Implementation + Test = ONE Task. Never separate.
> EVERY task MUST have: Recommended Agent Profile + Parallelization info + QA Scenarios.
> **A task WITHOUT QA Scenarios is INCOMPLETE. No exceptions.**

- [ ] 1. Project scaffolding + flake.nix

  **What to do**:
  - Create project directory structure: `hosts/`, `secrets/`, `pkgs/`, `deploy/`, `prometheus/`
  - Initialize `flake.nix` with nixpkgs and nvmd/nixos-raspberrypi inputs
  - Add comin input for GitOps provisioning
  - Add sops-nix input for secret management
  - Configure nixConfig with cachix substituters
  - Create `nixosConfigurations.rpi-kiosk` entry

  **Must NOT do**:
  - Don't add host-specific config yet (keep in hosts/)
  - Don't include WiFi secrets (encrypted separately)
  - Don't enable comin yet (configure after base system)

  **Recommended Agent Profile**:
  > Nix flake setup requires understanding of flake structure and input dependencies.
  - **Category**: `quick`
    - Reason: Standard flake setup, no complex logic
  - **Skills**: [`git-master`]
    - `git-master`: For proper git initialization and .gitignore
  - **Skills Evaluated but Omitted**:
    - `deep`: Not needed for basic flake structure

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2-7)
  - **Blocks**: All other tasks depend on flake.nix being valid
  - **Blocked By**: None (can start immediately)

  **References**:

  **Flake Pattern References**:
  - `nvmd/nixos-raspberrypi/flake.nix:inputs` - Standard flake input pattern
  - `nixos-raspberrypi/lib/default.nix:nixosSystem` - How to use nixos-raspberrypi.lib.nixosSystem

  **Why Each Reference Matters**:
  - `nvmd/nixos-raspberrypi/flake.nix:inputs` - Shows correct input structure for RPi5
  - `nixos-raspberrypi/lib/default.nix:nixosSystem` - Required for RPi5 configuration

  **Acceptance Criteria**:

  - [ ] `nix flake show` → Shows rpi-kiosk configuration
  - [ ] `nix flake lock` → Creates flake.lock without errors
  - [ ] `nix build .#nixosConfigurations.rpi-kiosk.config.system.build.toplevel` → Builds successfully

  **QA Scenarios (MANDATORY)**:

  ```
  Scenario: Flake validation
    Tool: Bash (nix commands)
    Preconditions: Empty project directory with flake.nix
    Steps:
      1. cd /path/to/project
      2. nix flake show
      3. nix flake lock
      4. nix build .#nixosConfigurations.rpi-kiosk.config.system.build.toplevel
    Expected Result: All commands succeed, toplevel build completes
    Failure Indicators: "error: attribute 'rpi-kiosk' not found", "build failed"
    Evidence: .sisyphus/evidence/task-1-flake-validation.txt

  Scenario: Module import validation
    Tool: Bash
    Preconditions: flake.nix with nvmd/nixos-raspberrypi input
    Steps:
      1. nix eval .#nixosConfigurations.rpi-kiosk.config.system.modules
      2. grep -q "raspberry-pi-5.base" <<< output
    Expected Result: raspberry-pi-5.base module is imported
    Failure Indicators: Module not found in output
    Evidence: .sisyphus/evidence/task-1-module-import.txt
  ```

  **Evidence to Capture**:
  - [ ] flake validation output
  - [ ] module import verification

  **Commit**: YES
  - Message: `feat(scaffolding): initial flake.nix with RPi5 base`
  - Files: `flake.nix`, `flake.lock`, `hosts/`, `pkgs/`, `secrets/`, `deploy/`, `prometheus/`
  - Pre-commit: `nix flake show`
325#RR|

---

## Final Verification Wave

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read file, curl endpoint, run command). For each "Must NOT Have": search codebase for forbidden patterns — reject with file:line if found. Check evidence files exist in .sisyphus/evidence/. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Code Quality Review** — `unspecified-high`
  Run `nix flake show` + `nix flake check` + linter. Review all Nix files for: `builtins` vs `pkgs`, unused imports, hardcoded paths, missing type safety. Check AI slop: excessive comments, over-abstraction, generic names (data/result/item/temp).
  Output: `Build [PASS/FAIL] | Lint [PASS/FAIL] | Nix files [N clean/N issues] | VERDICT`

- [ ] F3. **Real Manual QA** — `unspecified-high`
  Start from clean state. Execute EVERY QA scenario from EVERY task — follow exact steps, capture evidence. Test cross-task integration (features working together, not isolation). Test edge cases: empty state, invalid input, rapid actions. Save to `.sisyphus/evidence/final-qa/`.
  Output: `Scenarios [N/N pass] | Integration [N/N] | Edge Cases [N tested] | VERDICT`

- [ ] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual diff (git log/diff). Verify 1:1 — everything in spec was built (no missing), nothing beyond spec was built (no creep). Check "Must NOT do" compliance. Detect cross-task contamination: Task N touching Task M's files. Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

```
Task 1: `feat(scaffolding): initial flake.nix with RPi5 base` — hosts/, secrets/, pkgs/, deploy/, prometheus/, flake.nix, flake.lock, nix flake show
Task 2: `feat(secrets): age encryption setup with sops-nix` — age keys, sops-nix config, age encryption test
Task 3: `feat(secrets): WiFi credentials encrypted` — wifi.age, sops config, age decryption test
Task 4: `feat(security): SSH key-based authentication` — ssh keys, authorized_keys, sshd_config
Task 5: `feat(comin): GitOps module integration` — comin config, polling setup, metrics config
Task 6: `feat(monitoring): Prometheus + Grafana setup` — prometheus.yml, grafana config, dashboards
Task 7: `feat(deploy): SD card image build config` — build scripts, image generation, flash instructions
Task 8: `feat(system): RPi5 base configuration` — raspberry-pi-5.base, page-size-16k, display-vc4
Task 9: `feat(display): Wayland + Sway compositor` — sway config, wayland session, auto-start
Task 10: `feat(display): Display rotation config` — portrait rotation, 1080x1920, xrandr config
Task 11: `feat(display): USB touchscreen setup` — Waveshare 15.6", input drivers, calibration
Task 12: `feat(network): Network configuration (DHCP)` — networkd config, DHCP client, WiFi SSID
Task 13: `feat(power): Auto-boot on power` — systemd power management, power-on behavior
Task 14: `feat(apps): Firefox ESR installation` — firefox-esr package, version pinning, update disable
Task 15: `feat(apps): Kiosk mode configuration` — firefox flags, fullscreen, no UI, kiosk URL
Task 16: `feat(recovery): systemd service with watchdog` — firefox.service, Restart=always, RestartSec=5s
Task 17: `feat(recovery): Memory leak mitigation` — Firefox memory limits, crash prevention, resource monitoring
Task 18: `feat(apps): Display brightness control` — backlight config, auto-brightness, sleep behavior
Task 19: `feat(monitoring): Prometheus server config` — prometheus.yml, scrape configs, retention policy
Task 20: `feat(monitoring): Grafana dashboards` — grafana dashboards, HA connectivity, system metrics
Task 21: `feat(monitoring): HA connectivity checks` — health check exporter, uptime monitoring, alerting
Task 22: `feat(monitoring): Alerting rules` — prometheus alerting, notification channels, severity levels
Task 23: `feat(system): Logging configuration` — journald config, log rotation, remote logging
Task 24: `feat(comin): GitOps sync setup` — comin polling, testing branch, rollback trigger
Task 25: `feat(comin): Testing branch workflow` — PR workflow, staging deployment, auto-promote
Task 26: `feat(comin): Rollback mechanism` — version history, quick rollback, recovery point
Task 27: `feat(integration): Full integration test` — end-to-end test, all features, smoke test
Task 28: `feat(deploy): SD card image build` — image generation, flash instructions, deployment script
Task 29: `docs(deploy): Deployment documentation` — README, setup guide, troubleshooting, maintenance
Task 30: `qa(final): Final QA pass` — run all scenarios, capture evidence, verify acceptance criteria
```

---

## Success Criteria

### Verification Commands

```bash
# System boots correctly
systemctl list-units --type=service | grep -q firefox-kiosk

# Firefox is running
ps aux | grep -q firefox-esr --kiosk

# WiFi connected
nmcli device wifi show | grep -q "Connected"

# SSH access works
ssh -i ~/.ssh/id_ed25519 pi@<RPi-IP> "echo 'OK'"

# comin polling active
systemctl status comin | grep -q "active (running)"

# Prometheus scraping
curl -s http://localhost:9090/api/v1/status | grep -q "ok"

# Grafana accessible
curl -s http://localhost:3000/api/health | grep -q "ok"

# HA connectivity
curl -s http://<HA-URL>/api/states | grep -q "200"

# Touchscreen working
cat /dev/input/event* | grep -q "touchscreen"

# Display rotated
xrandr | grep -q "1080x1920"
```

### Final Checklist
- [ ] All "Must Have" present (see Work Objectives)
- [ ] All "Must NOT Have" absent (see Guardrails)
- [ ] All acceptance criteria pass
- [ ] All QA scenarios executed
- [ ] Evidence files captured
- [ ] Git commit history clean
- [ ] Documentation complete

---

## Plan Generated: rpi-kiosk

**Key Decisions Made:**
- **RAM**: 2GB model (user prefers to try first, upgrade if fails)
- **Display Server**: Wayland + Sway (modern RPi5 support)
- **Firefox**: ESR version + disable auto-updates (stability focus)
- **Auto-Recovery**: systemd Service Watchdog (restart=always)
- **Monitoring**: Full stack (Prometheus + Grafana)
- **Secrets**: age encryption via SOPS, stored in same Git repo as config
- **Deployment**: SD card image (recommended for RPi5)

**Scope:**
- **IN**: RPi5 base config, Sway + Wayland, Firefox kiosk, systemd recovery, comin GitOps, age-encrypted WiFi, Prometheus + Grafana, SSH access, touchscreen, portrait rotation, SD card image
- **OUT**: Audio, Bluetooth, GUI desktop environments, automatic Firefox updates, remote desktop, hardware watchdog, motion detection, complex UI customizations

**Guardrails Applied:**
- No GUI desktop environment (GNOME/KDE)
- No audio (explicitly disabled)
- No Bluetooth (security risk)
- No automatic Firefox updates (stability)
- No user accounts (root-only kiosk)
- No remote desktop (SSH only)
- No hardware watchdog (software only)

**Auto-Resolved** (minor gaps fixed):
- **Acceptance criteria**: All converted to executable commands
- **Edge cases**: HA downtime, network partitions, memory leaks handled in tasks
- **Security**: SSH keys + firewall + comin auth configured

**Defaults Applied** (override if needed):
- **Firefox version**: ESR (default for stability)
- **WiFi**: Single network, DHCP (default for simplicity)
- **Monitoring**: Prometheus + Grafana (default for full visibility)

---

## Next Steps

**Plan is complete. How would you like to proceed?**

1. **Start Work**: Execute now with `/start-work rpi-kiosk`. Plan looks solid.
2. **High Accuracy Review**: Have Momus rigorously verify every detail. Adds review loop but guarantees precision.

**Note**: Draft file `.sisyphus/drafts/rpi-kiosk.md` contains all requirements and decisions. Delete after plan complete.

(continuing in next edit...)