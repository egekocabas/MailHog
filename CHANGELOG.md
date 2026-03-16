# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-03-16

### Added

- `GET /mailhog/status` — returns running state, container ID, container name, and host port bindings
- `POST /mailhog/start` — creates and starts the MailHog container; binds host ports when configured
- `POST /mailhog/stop` — stops and removes the managed container
- `POST /mailhog/restart` — stop + remove + recreate with new port config in one call
- `POST /mailhog/test` — sends an SMTP message via the internal network and verifies receipt through the MailHog API
- `GET /mailhog/settings` / `POST /mailhog/settings` — persist port config, zoom level, and test email field values to `/root/mailhog/settings.json`
- Container label (`com.egekocabas.mailhog-extension`) used to track the managed container across backend restarts
- Dedicated Docker bridge network `mailhog-extension-network`; backend connects to it at startup so container-name DNS is not required — IP address is resolved via `ContainerInspect` and cached in memory
- Port conflict detection against all running containers before `ContainerCreate`
- `ContainerName` field added to status response (used by the frontend header tooltip)
- Frontend: setup screen with optional host port binding (0 = no binding) and settings restored from backend on load
- Frontend: running header with container name tooltip on the status chip, open-in-browser shortcut next to Web UI port info
- Frontend: embedded MailHog iframe with zoom controls; MailHog navbar brand and GitHub link hidden via positioned overlay divs (cross-origin CSS injection is not possible)
- Frontend: test email form with placeholder defaults, two-column layout, send + clear actions, and last-used field values saved to backend settings
- Frontend: layout uses `position: fixed; inset: 0` on the root container to prevent page scroll from pushing the header out of view
