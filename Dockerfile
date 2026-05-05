# --- Stage 1: Build CLI ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git

WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 1. ADD THE JS TO THE REPO BEFORE BUILD
# We place it in the 'starboard' subfolder where the Go code is.
WORKDIR /src/starboard
RUN mkdir -p static/vendor/starboard-wrap@0.2.5/dist/ && \
    curl -L https://unpkg.com/starboard-wrap@0.2.5/dist/index.min.js \
    -o static/vendor/starboard-wrap@0.2.5/dist/index.min.js

# 2. Compile the binary 
# Go will now package the 'static' folder (including our new JS) into the executable
RUN go mod download
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Final Image ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

# Now the binary carries the JS file 'on its back'
ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
