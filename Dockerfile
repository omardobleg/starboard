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
# 2. THE TOTAL OVERRIDE
# We search for any string starting with http://localhost and ending in the vendor path.
# We replace it with the unpkg equivalent. 
# We run this on the entire directory to catch it in Go files AND templates.
RUN find internal/nbserver -type f -print0 | xargs -0 sed -i 's|http://localhost:[0-9]*/static/vendor|https://unpkg.com|g'

# 3. VERIFICATION
# This will show us if any file still contains "localhost" in that directory.
RUN grep -r "localhost" internal/nbserver || true
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
