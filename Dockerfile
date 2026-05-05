# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Install git and build-base (for compiling)
RUN apk add --no-cache git build-base

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Fix the Module error: Initialize a module and fetch dependencies manually
# This repo uses Cobra (CLI) and Watcher (for live reloading)
RUN go mod init starboard-build && \
    go get github.com/spf13/cobra && \
    go get github.com/radovskyb/watcher && \
    go mod tidy

# 3. Build the binary
# We use -o to name the output and . to build from the current directory
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the binary from the builder
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
