# Release Notes — v1.0.0

**Released:** March 16, 2026

---

## Overview

This is the first release of the MailHog Docker Desktop Extension. It brings MailHog — a popular lightweight SMTP testing server — directly into Docker Desktop, so you can capture, inspect, and test emails from your local development environment without leaving the app.

---

## What's included

### Start MailHog in one click

On first launch you are presented with a setup screen where you can configure host port bindings for the Web UI and SMTP server before starting MailHog. Both ports are optional — setting either to `0` skips host binding entirely, keeping MailHog accessible only within the extension. Your port configuration is saved and restored automatically on the next launch.

If MailHog was already running when you reopen the extension, it resumes automatically without requiring any manual action.

### Manage MailHog from the header

Once MailHog is running, a persistent header bar shows the current status, bound ports, and the name of the managed container. From here you can:

- **Restart** — opens a dialog to reconfigure Web UI and SMTP ports, then recreates the container with the new settings
- **Stop** — stops and removes the container, returning to the setup screen
- **Open in browser** — opens the MailHog Web UI in your default browser directly from the port info in the header

### Browse captured emails

The **Web UI** tab embeds the full MailHog inbox inside the extension. Emails captured by MailHog appear here in real time. Zoom controls let you scale the view up or down to your preference, and your zoom level is saved between sessions.

### Send test emails

The **Test Email** tab lets you send a test email directly to MailHog from within the extension to verify your setup is working. Fill in the From, To, Subject, and Body fields — or leave them blank to use the built-in placeholder values. After sending, the extension checks the MailHog API to confirm the email was received and shows a delivery result.

The fields you fill in are saved to the backend and restored the next time you open the tab, so you don't have to retype them on every test.

---

## Connecting your application

If you started MailHog with host port binding enabled, point your application's SMTP client to:

```
Host: localhost
Port: 1025  (or whichever SMTP port you configured)
```

Emails your application sends will be captured by MailHog and visible in the Web UI tab instead of being delivered to real recipients.

---

## Notes

- This extension is not affiliated with the official MailHog project. See [github.com/mailhog/MailHog](https://github.com/mailhog/MailHog) for the upstream project.
- The extension backend runs entirely inside Docker Desktop and does not make any external network calls.
