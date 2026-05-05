# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Install git
RUN apk add --no-cache git

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Move into the directory where the Go code and go.mod actually live
WORKDIR /src/starboard

# 3. Download the dependencies defined in the existing go.mod
RUN go mod download

# 4. Build the binary
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Copy the ARM64 binary we just built
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Start the server
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
