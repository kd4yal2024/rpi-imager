# Changelog

## 2026-02-28

### Added
- New wizard step: `ProvisioningCustomizationStep` for optional first-boot repository provisioning.
- Provisioning state surfaced in wizard progress and write/done summaries.
- Provisioning URL validation for GitHub repository URLs in UI and backend.

### Changed
- Cloud-init customization flow now merges standard wizard cloud-init settings with repository provisioning cloud-init, instead of replacing base settings.
- Provisioning fetch/parser logic now consistently handles GitHub repo URLs and `tree/<branch>/<path>` forms.
- Runtime customization now merges with persisted customization settings before generation to keep user/SSH/Wi-Fi/locale settings intact.
- Update checks/popups are disabled in this build.

### Fixed
- Resolved QML stack overflow (`RangeError: Maximum call stack size exceeded`) observed in provisioning customization flow.
- Fixed cloud-init payload handling for multipart user-data:
  - multipart payloads are no longer incorrectly prefixed as plain `#cloud-config`
  - defensive normalization strips non-MIME prefixes before writing `user-data`
- Added fallback behavior: provisioning fetch failures now fall back to standard cloud-init customization instead of leaving customization invalid.

### Diagnostics
- Added debug logging for provisioning merge sizes and detected cloud-init payload format to simplify troubleshooting.
