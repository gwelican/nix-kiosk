
## Task 2: Age Encryption Setup with SOPS-NIX

### Summary
Configured age encryption and sops-nix for secret management.

### Files Created/Modified
- `secrets/age.key` - Age private key pair (189 bytes)
- `.sops.yaml` - SOPS configuration with age public key
- `hosts/rpi-kiosk.nix` - Added sops.age.keyFile configuration
- `flake.nix` - Added sops-nix module to nixosConfigurations modules list

### Age Public Key
```
age1xkmwtyqgtpsusgtcjcu2atjl8c0qvq0wtfctnq5erpwahpleeawq4e76h8
```

### Configuration Details
- `.sops.yaml` configured to encrypt files matching `secrets/.+` using age
- sops-nix module passed directly in flake.nix (not via host imports)
- Host configuration references keyFile as relative path: `./secrets/age.key`

### Notes
- Build verification failed due to architecture mismatch (aarch64-linux vs x86_64-linux on host)
- Flake configuration validated successfully via `nix flake show`
- Nix syntax validated via `nix-instantiate --parse`

## Task 3: WiFi secrets encrypted

### Approach
- Created `secrets/wifi.yaml` with placeholder credentials (SSID: kiosk-network, PSK: placeholder-password)
- Added comment instructing user to replace credentials before deployment
- Created `secrets/.sops.yaml` to configure sops encryption rules for secrets/*.yaml files
- Encrypted using: `sops -e --age age1xkmwtyqgtpsusgtcjcu2atjl8c0qvq0wtfctnq5erpwahpleeawq4e76h8 --input-type yaml --output-type yaml secrets/wifi.yaml`
- Verified decryption using: `SOPS_AGE_KEY_FILE=secrets/age.key sops -d --input-type yaml --output-type yaml secrets/wifi.age`

### Key Learnings
- sops requires `--input-type` and `--output-type` flags for YAML files
- Decryption requires SOPS_AGE_KEY_FILE env var or key in ~/.config/sops/age/keys.txt
- Age encryption key format: `age1xkmwtyqgtpsusgtcjcu2atjl8c0qvq0wtfctnq5erpwahpleeawq4e76h8`
- Placeholder credentials are safe for public Git repos
