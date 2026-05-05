# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Git is required to fetch dependencies
RUN apk add --no-cache git

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Build the binary
# We tell Go to build the package located in the 'starboard' directory.
# This will automatically use the go.mod found in the root.
RUN CGO_ENABLED=0 go build -o /app/starboard ./starboard

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the binary from the builder stage
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
