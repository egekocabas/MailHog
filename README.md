# MailHog Docker Desktop Extension

## Overview

This project is a **Docker Desktop Extension** that provides an integrated developer experience for running and interacting with **MailHog** directly from Docker Desktop.

MailHog is a lightweight SMTP server designed for testing email delivery during development. Instead of sending real emails, MailHog captures them and exposes them via a web UI and API.

This extension allows developers to:

- Launch and manage a MailHog container directly from Docker Desktop
- Configure the SMTP and UI ports
- View captured emails inside the extension UI
- Test SMTP functionality from within the extension
- Run everything without exposing the extension backend to the host unless explicitly configured

The extension follows **Docker Desktop extension best practices**:

- No host port binding for the extension backend
- A helper backend responsible only for orchestration
- MailHog running as a managed container
- Optional host port exposure when needed
- Internal Docker networking for container-to-container communication

---

# Architecture

The extension consists of three primary components:

1. **Extension Frontend**
2. **Extension Helper Backend**
3. **Managed MailHog Container**


## Docker Desktop
```
│
├── Extension UI (React / Web UI)
│
├── Extension Backend (helper service)
│ │
│ ├── Docker Engine API
│ │
│ └── MailHog container
│
└── Docker Network (shared network)
```

## Responsibilities

### Extension UI

The frontend provides the user interface for:

- configuring ports
- starting and stopping MailHog
- viewing the MailHog web interface
- sending test emails
- displaying status and diagnostics

The UI communicates with the backend using the Docker Desktop extension API.

### Extension Backend

The backend is a lightweight service that performs orchestration tasks:

- creating and managing the MailHog container
- attaching containers to the extension network
- checking MailHog readiness
- sending SMTP test emails
- querying the MailHog API

The backend **does not publish ports to the host** and is only accessible from the extension UI.

### MailHog Container

MailHog runs as a standard Docker container:

```
mailhog/mailhog
```

Default ports inside the container:

| Service | Port |
|--------|------|
| SMTP   | 1025 |
| Web UI | 8025 |
| API    | 8025 |

---

# Networking Design

The extension creates a **dedicated Docker network**.

Example:

```
mailhog-extension-network
```

Both the backend and MailHog containers join this network.

```
Extension Backend
│
│ SMTP
▼
mailhog:1025
```

This allows the backend to communicate with MailHog internally without publishing ports to the host.

Benefits:

- avoids host port conflicts
- improves security
- keeps the extension self-contained

---

# Optional Host Port Exposure

If the user wants applications running on their machine to send emails to MailHog, the extension can optionally publish ports.

Example configuration:

```
SMTP Host Port: 2525
UI Host Port: 8026
```

The extension backend recreates the MailHog container with:

```
docker run -d
--name mailhog-extension
-p 2525:1025
-p 8026:8025
--network mailhog-extension-network
mailhog/mailhog
```

Local applications can then use:

```
SMTP Host: localhost
SMTP Port: 2525
```

---

# Extension UI Features

## Setup Page

The setup page allows the user to configure:

- SMTP port (optional host binding)
- UI port (optional host binding)

Controls:

- Start MailHog
- Stop MailHog
- Restart MailHog

---

## MailHog Inbox View

After MailHog starts, the extension UI displays the MailHog interface.

Options:

- embed via iframe
- open in browser
- proxy through the extension backend

---

## SMTP Test Tab

This tab allows the user to test email delivery.

Workflow:

1. UI requests test email
2. Backend sends SMTP message
3. Backend verifies receipt via MailHog API
4. UI shows result

---

# SMTP Test Workflow

The backend performs the following steps:

1. Ensure MailHog container is running
2. Send SMTP message to:

```
mailhog:1025
```

3. Poll MailHog API:

```
http://mailhog:8025/api/v2/messages
```

4. Confirm message delivery

Sequence diagram:

```
UI
│
│ request test
▼
Backend
│
│ SMTP send
▼
MailHog
│
│ store message
▼
Backend
│
│ query API
▼
UI
```

---

# Container Lifecycle Management

The backend manages the MailHog container.

Operations include:

### Start


`docker run ...`


### Stop


`docker stop mailhog-extension`


### Remove


`docker rm mailhog-extension`


### Recreate

When configuration changes:

1. stop container
2. remove container
3. recreate with new ports

---

# Why a Helper Backend Exists

Although Docker Desktop extensions can execute Docker CLI commands directly from the frontend, the helper backend is used because it provides:

- controlled container lifecycle management
- SMTP testing capability
- better error handling
- networking management
- cleaner architecture

The backend acts as an orchestration layer rather than a user-facing service.

---

# Security Considerations

The backend may interact with the Docker Engine through the Docker socket.

This provides powerful capabilities:

- container creation
- container removal
- container inspection

Because of this, users should trust the extension before installing it.

The extension avoids unnecessary host port exposure and limits functionality to MailHog orchestration.

---

# Why MailHog

MailHog is widely used for development email testing and provides:

- SMTP server
- web interface
- REST API
- simple Docker image

Official repository:

https://github.com/mailhog/MailHog

---

# Summary

This extension provides a developer-friendly way to run MailHog inside Docker Desktop.

Key principles:

- extension backend remains internal
- MailHog runs as a managed container
- container communication happens via Docker networks
- host ports are optional and user-controlled
- SMTP testing is performed internally via the backend

The result is a flexible, secure, and Docker-native developer tool.