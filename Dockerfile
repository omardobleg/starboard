# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder

# Install git
RUN apk add --no-cache git

WORKDIR /src

# 1. Clone the repo
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 2. Setup the module system manually
# We name it 'starboard' and fetch the two libraries the code uses
RUN go mod init github.com/gzuidhof/starboard-cli && \
    go get github.com/spf13/cobra && \
    go get github.com/radovskyb/watcher

# 3. Build it
# We point to "." which tells Go "build the package in the current directory"
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Runner ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates

COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
