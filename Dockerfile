# --- Stage 1: Build CLI ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .
WORKDIR /src/starboard
RUN go mod download
# We build the binary here
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Final Image ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates curl

COPY --from=builder /app/starboard /usr/local/bin/starboard

# FIX: Manually create the directory structure the 404 is looking for
WORKDIR /static/vendor/starboard-wrap@0.2.5/dist/
RUN curl -L https://unpkg.com/starboard-wrap@0.2.5/dist/index.min.js -o index.min.js

# Return to notebook directory
WORKDIR /notebooks
EXPOSE 8000

ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
