# PACKAGES KNOWLEDGE BASE

**Generated:** 2026-02-26
**Commit:** e2b98d2
**Branch:** master

## OVERVIEW

Custom Nix package definitions for the RPi5 kiosk: comin (Rust GitOps tool) and ha-health-exporter (Python HA API exporter).

## STRUCTURE

```
pkgs/
├── comin/
│   └── default.nix    # Rust package via rustPlatform.buildRustPackage
└── ha-health-exporter/
    ├── default.nix    # Python package via stdenv.mkDerivation
    └── ha-health-exporter.py  # Python implementation
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new package | `pkgs/<name>/default.nix` | Use `rustPlatform` or `stdenv.mkDerivation` |
| Modify comin version | `pkgs/comin/default.nix:9` | Update version + cargoHash |
| Modify HA exporter | `pkgs/ha-health-exporter/ha-health-exporter.py` | Python code |

## CONVENTIONS

- **Comin package**: Uses `rustPlatform.buildRustPackage` with GitHub source
- **HA exporter**: Uses `stdenv.mkDerivation` with Python setuptools
- **Hashes**: Update `cargoHash` when source changes (placeholder currently)
- **Meta**: Include `description`, `homepage`, `license`, `maintainers`, `platforms`

## ANTI-PATTERNS (THIS DIRECTORY)

- ❌ Hardcoded paths in package definitions
- ❌ Using `pkgs` instead of `lib` for meta fields
- ❌ Missing `platforms = platforms.linux` for embedded tools