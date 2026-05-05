# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Git is required to clone and fetch dependencies
RUN apk add --no-cache git

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Move into the actual Go source folder
WORKDIR /src/starboard

# 3. Setup the module environment
# The repo is older and lacks a go.mod, so we create one and tidy it
RUN go mod init github.com/gzuidhof/starboard-cli && \
    go mod tidy

# 4. Build the binary
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the fresh ARM64 binary from the builder
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server on all interfaces so Dokploy can route to it
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
