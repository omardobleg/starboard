# --- Stage 1: Build the CLI ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .
WORKDIR /src/starboard
RUN go mod download
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Final Image ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates curl

# 1. Install the CLI binary from Stage 1
COPY --from=builder /app/starboard /usr/local/bin/starboard

# 2. Download the actual Starboard Frontend (The Editor)
# We download the bundled web player so the CLI has something to serve
WORKDIR /starboard-ui
RUN curl -L https://unpkg.com/starboard-notebook/dist/index.html -o index.html

WORKDIR /notebooks
EXPOSE 8000

# We use the 'serve' command
# If the editor still doesn't show, Starboard usually pulls the UI from the CDN
# by default, so we ensure the container has internet access.
ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
