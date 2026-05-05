# --- Stage 1: Build specifically for the host architecture ---
FROM golang:1.21-alpine AS builder

# Install git and build essentials
RUN apk add --no-cache git build-base

WORKDIR /src

# Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# Build the binary. 
# CGO_ENABLED=0 makes the binary "static" and more portable.
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Tiny Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the binary we just built
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
