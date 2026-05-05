# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git

WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# Move to the source folder and build
WORKDIR /src/starboard
RUN go mod download
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the binary
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Removed --host as it's not a valid flag for this CLI
# It defaults to 0.0.0.0:8000 or 127.0.0.1:8000; Dokploy will handle the routing.
ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
