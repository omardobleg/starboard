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

# 1. Create the EXACT path that worked for you under /browse
# Since the server adds /browse to the working directory, 
# we put the file in static/... right where we start.
WORKDIR /notebooks/static/vendor/starboard-wrap@0.2.5/dist/
RUN curl -L https://unpkg.com/starboard-wrap@0.2.5/dist/index.min.js -o index.min.js

# 2. THE FIX: Create a duplicate at the system root just in case
RUN mkdir -p /static/vendor/starboard-wrap@0.2.5/dist/ && \
    cp index.min.js /static/vendor/starboard-wrap@0.2.5/dist/index.min.js

WORKDIR /notebooks

# 3. Create a starting notebook
RUN echo "# %% [markdown]\n# Welcome to Starboard\n" > my-first-notebook.starboard

EXPOSE 8000

# We run with the -v (verbose) flag if available to see path errors in Dokploy logs
ENTRYPOINT ["starboard", "serve", "--port", "8000", "."]
