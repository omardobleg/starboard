# --- Stage 1: Build using the official Go installer ---
FROM golang:1.21-alpine AS builder

# Git is still needed for Go to fetch the source code
RUN apk add --no-cache git

# This command fetches, resolves dependencies, and builds the binary automatically
# It will place the resulting binary in /go/bin/
RUN go install github.com/gzuidhof/starboard-cli@latest

# --- Stage 2: Tiny Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Note: 'go install' names the binary based on the repo name (starboard-cli)
# We copy it over and rename it to just 'starboard' for convenience
COPY --from=builder /go/bin/starboard-cli /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
