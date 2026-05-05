# --- Stage 1: Build CLI ---
FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git
WORKDIR /src
RUN git clone https://github.com/gzuidhof/starboard-cli.git .
WORKDIR /src/starboard
RUN go mod download
RUN CGO_ENABLED=0 go build -o /app/starboard .

# --- Stage 2: Final Image ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates curl

COPY --from=builder /app/starboard /usr/local/bin/starboard

# We create the static folder INSIDE the notebooks directory
# This ensures that when the server runs in ".", it finds the static files
WORKDIR /notebooks/static/vendor/starboard-wrap@0.2.5/dist/
RUN curl -L https://unpkg.com/starboard-wrap@0.2.5/dist/index.min.js -o index.min.js

# Go back to the notebooks root
WORKDIR /notebooks

# Initialize a default notebook so the editor has something to load
RUN echo "# %% [markdown]\n# Welcome to Starboard on Pi 4\n" > my-first-notebook.starboard

EXPOSE 8000

# Run the server from /notebooks
ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
