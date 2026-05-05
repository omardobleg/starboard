# --- Stage 1: Build CLI ---
FROM golang:1.21-alpine AS builder

# Add curl here so we can download the JS file
RUN apk add --no-cache git curl

WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .

# 1. ADD THE JS TO THE REPO BEFORE BUILD
WORKDIR /src/starboard
RUN mkdir -p web/static/vendor/starboard-wrap@0.2.5/dist/ && \
    curl -L https://unpkg.com/starboard-wrap@0.2.5/dist/index.min.js \
    -o web/static/vendor/starboard-wrap@0.2.5/dist/index.min.js

# 2. THE TAB-PROOF REPAIR
# We use [[:space:]] to catch those ^I tabs you found.
RUN sed -i -E 's|iframeHost:[[:space:]]*"http://localhost:"[[:space:]]*\+[[:space:]]*portSecondary|iframeHost: "https://unpkg.com"|g' internal/nbserver/handler.go

# 3. VERIFICATION
# If this returns the unpkg line in your Dokploy logs, it's finally fixed!
RUN grep "iframeHost" internal/nbserver/handler.go

# 2. Compile the binary 
RUN go mod download
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Final Image ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/starboard /usr/local/bin/starboard

WORKDIR /notebooks
EXPOSE 8000

ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
