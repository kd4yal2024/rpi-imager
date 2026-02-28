## Windows MSI - Saturn Provisioning Build

Custom Raspberry Pi Imager build with Saturn provisioning workflow fixes.

### Included changes
- Adds a dedicated Provisioning wizard step.
- Supports provisioning source config via GitHub URL / branch / path.
- Merges base wizard cloud-init with repo provisioning cloud-init.
- Fixes multipart cloud-init handling for first-boot execution.
- Preserves base custom settings (user, SSH, Wi-Fi, locale, hostname) when provisioning is enabled.
- Falls back to standard cloud-init customization if provisioning fetch fails.
- Disables startup update popup checks in this custom build.
- Adds `CHANGELOG.md` with implementation notes.

### Artifact
- `rpi-imager-custom-0.1.1-win64.msi`

### Notes
- This build is intended for repeatable Saturn image provisioning.
- Repo-side provisioning scripts are still evolving for full hardware coverage.
- For unattended provisioning, set `SATURN_ADMIN_PASSWORD` to avoid interactive installer prompts.
