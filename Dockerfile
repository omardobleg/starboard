# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Install git
RUN apk add --no-cache git

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Move into the actual code directory
# The repo structure has the Go files inside the /starboard folder
WORKDIR /src/starboard

# 3. Setup the module and build
# We initialize it locally so it doesn't try to find a remote go.mod
RUN go mod init github.com/gzuidhof/starboard-cli && \
    go mod tidy

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
