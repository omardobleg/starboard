# --- Stage 1: Build ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .
RUN go build -o /app/starboard .

# --- Stage 2: Run ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/starboard /usr/local/bin/starboard
WORKDIR /notebooks
EXPOSE 8000
# Important: We listen on 0.0.0.0 so Dokploy's proxy can reach it
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
