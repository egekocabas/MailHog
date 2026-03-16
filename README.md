<p align="center">
  <img src="assets/extension-icon.svg" width="180" alt="MailHog Extension Icon" />
</p>

<h1 align="center">MailHog Docker Desktop Extension</h1>

<p align="center">
  <a href="https://hub.docker.com/r/egekocabas/mailhog"><img src="https://img.shields.io/docker/pulls/egekocabas/mailhog?label=pulls" alt="Docker Pulls" /></a>
  <a href="https://hub.docker.com/r/egekocabas/mailhog"><img src="https://img.shields.io/docker/image-size/egekocabas/mailhog/latest?label=image%20size" alt="Image Size" /></a>
  <a href="https://hub.docker.com/r/egekocabas/mailhog"><img src="https://img.shields.io/docker/v/egekocabas/mailhog?label=version" alt="Version" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/egekocabas/mailhog" alt="License" /></a>
</p>

A [Docker Desktop](https://www.docker.com/products/docker-desktop/) extension for running [MailHog](https://github.com/mailhog/MailHog) locally.

> **Disclaimer:** This project is not affiliated with the official MailHog project. It is an independent Docker Desktop extension for running MailHog containers locally.

---

## What it does

MailHog is a lightweight SMTP testing server that captures outgoing emails instead of delivering them. This extension lets you start, manage, and interact with a MailHog container directly inside Docker Desktop.

- Start and stop MailHog with one click
- Configure optional host port bindings for SMTP and Web UI
- Browse captured emails via the embedded Web UI
- Send test emails and verify delivery from within the extension
- Settings are persisted across sessions

---

## Installation

Install from the [Docker Desktop Extensions Marketplace](https://hub.docker.com/extensions/egekocabas/mailhog) or run:

```sh
docker extension install egekocabas/mailhog:latest
```

---

## Usage

### Starting MailHog

On first launch you will see the setup screen. Configure the host ports and click **Start**.

| Field | Default | Description |
|---|---|---|
| Web UI Port | 8025 | Binds the MailHog web interface to your host |
| SMTP Port | 1025 | Binds the SMTP server to your host |

Set either port to **0** to skip host binding. MailHog will still run internally — only the extension won't expose that port on your machine.

- **Web UI tab** — displays the MailHog inbox embedded in the extension. Use the zoom controls to adjust the view. The **Open in browser** button next to the Web UI port in the header opens MailHog in your default browser.
- **Test Email tab** — send a test email directly from the extension to verify your MailHog setup.
- **Restart** — use the **Restart** button in the header to reconfigure ports.
- **Stop** — use the **Stop** button to shut down the MailHog container. The extension returns to the setup screen.

---

## Architecture

Three components work together:

| Component | Description |
|---|---|
| **Frontend** | React + TypeScript UI, communicates with the backend via Docker Desktop's extension API |
| **Backend** | Go service (Echo framework) running on a Unix socket inside the extension container, orchestrates the MailHog container via the Docker Engine API |
| **MailHog container** | `mailhog/mailhog` Docker image, connected to a dedicated bridge network (`mailhog-extension-network`) |

The backend communicates with MailHog over the internal Docker network using the container's IP address — no host ports are required for this communication.

---

## Contributing

This project is considered feature-complete and pull requests are not currently being accepted. Bug reports and feature requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## License

[MIT](LICENSE) © Ege Kocabaş
