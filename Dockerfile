# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Git and build-base are required for fetching and compiling
RUN apk add --no-cache git build-base

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Build without the Module system (Old School mode)
# We set GO111MODULE=off so it doesn't look for a go.mod file.
# We include all .go files in the root to ensure dependencies are linked.
RUN GO111MODULE=off CGO_ENABLED=0 go build -o /app/starboard *.go

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the binary from the builder
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
