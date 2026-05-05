# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Install git and build tools
RUN apk add --no-cache git build-base

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Force-initialize the module system to fix the "cannot find main module" error
# This creates a dummy go.mod that tells Go "treat this folder as the source"
RUN go mod init starboard-build || true
RUN go mod tidy

# 3. Build the binary statically
# We use -o starboard to name the output file
RUN CGO_ENABLED=0 go build -o /app/starboard main.go

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the binary from the builder
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
