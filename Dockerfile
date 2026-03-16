FROM golang:1.25-alpine AS builder
ENV CGO_ENABLED=0
WORKDIR /backend
COPY backend/go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download
COPY backend/. .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -trimpath -ldflags="-s -w" -o bin/service

FROM --platform=$BUILDPLATFORM node:24-alpine AS client-builder
WORKDIR /ui
# cache packages in layer
COPY ui/package.json /ui/package.json
COPY ui/package-lock.json /ui/package-lock.json
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm ci
# install
COPY ui /ui
RUN npm run build

FROM alpine
LABEL org.opencontainers.image.title="MailHog"
LABEL org.opencontainers.image.description="Run and manage MailHog SMTP testing server directly in Docker Desktop. Capture emails locally, inspect them via a built-in web UI, and send test emails — no external mail server needed."
LABEL org.opencontainers.image.vendor="Ege Kocabaş"
LABEL com.docker.desktop.extension.api.version="0.4.2"
LABEL com.docker.extension.screenshots="[\
    {\"alt\": \"Home\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/1_home.png\"},\
    {\"alt\": \"Landing\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/2_landing.png\"},\
    {\"alt\": \"Send Email\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/3_send_email.png\"},\
    {\"alt\": \"Email View\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/4_email_view.png\"},\
    {\"alt\": \"Restart\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/5_restart.png\"},\
    {\"alt\": \"Landing (Dark)\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/6_landing.png\"},\
    {\"alt\": \"Home (Dark)\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/7_home.png\"},\
    {\"alt\": \"Send Email (Dark)\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/8_send_email.png\"},\
    {\"alt\": \"Email View (Dark)\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/9_email_view.png\"},\
    {\"alt\": \"Send Email (Local)\", \"url\": \"https:\/\/raw.githubusercontent.com\/egekocabas\/mailhog\/refs\/heads\/main\/assets\/10_send_email_local.png\"}]"
LABEL com.docker.desktop.extension.icon="https://raw.githubusercontent.com/egekocabas/mailhog/refs/heads/main/assets/extension-icon.svg"
LABEL com.docker.extension.detailed-description="\
    A Docker Desktop extension for running MailHog — a lightweight SMTP testing server that captures outgoing emails instead of delivering them. \
    Ideal for local development and testing email flows without a real mail server.<br><br>\
    <b>Key Features:</b><br><br>\
    - One-click MailHog container start, stop, and restart<br>\
    - Optional host port binding for SMTP (default 1025) and Web UI (default 8025)<br>\
    - Embedded MailHog inbox view<br>\
    - Built-in test email sender<br>\
    - Persistent settings across sessions<br><br>\
    <b>Architecture:</b><br><br>\
    - <b>Backend (Go)</b>: Runs on a Unix socket inside the extension container; manages the MailHog container via the Docker Engine API and handles SMTP test sending<br>\
    - <b>Frontend (React/TypeScript)</b>: Communicates with the backend exclusively through the Docker Desktop extension API<br>\
    - <b>MailHog container</b>: <code>mailhog/mailhog</code> image, connected to a dedicated Docker bridge network for internal communication<br><br>\
    <b>Usage:</b><br>\
    - Install the extension<br>\
    - Configure Web UI and SMTP host ports (set to 0 to skip host binding)<br>\
    - Click Start — MailHog is ready to capture emails<br>\
    - Use the Test Email tab to verify your setup<br>\
    - Point your application's SMTP client to <code>localhost:1025</code><br><br>\
    <b>Note:</b> This extension is not affiliated with the official MailHog project. It is an independent Docker Desktop extension for running MailHog containers locally.<br><br>"
LABEL com.docker.extension.publisher-url="https://github.com/egekocabas/mailhog"
LABEL com.docker.extension.additional-urls="\
    [{\"title\":\"GitHub\",\"url\":\"https:\/\/github.com\/egekocabas\/mailhog\"},\
    {\"title\":\"MIT License\",\"url\":\"https://github.com/egekocabas/mailhog/blob/main/LICENSE\"}]"
LABEL com.docker.extension.categories="utility-tools"
LABEL com.docker.extension.changelog="<ul><li>Initial release</li></ul>"
LABEL com.docker.extension.account-info=""

COPY --from=builder /backend/bin/service /
COPY compose.yaml .
COPY metadata.json .
COPY assets/extension-icon.svg .
COPY --from=client-builder /ui/build ui
CMD /service -socket /run/guest-services/backend.sock
