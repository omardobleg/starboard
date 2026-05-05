# Use a lightweight base
FROM arm32v7/alpine:latest

# Install curl to download the binary
RUN apk add --no-cache curl ca-certificates

# 1. Define the version and architecture
# For most servers (including Dokploy), this will be 'amd64'
ARG VERSION=v0.3.3
ARG ARCH=arm64

# 2. Download the binary directly from GitHub Releases
# We name it 'starboard' and move it to the bin folder
RUN curl -L "https://github.com/gzuidhof/starboard-cli/releases/download/${VERSION}/starboard-linux-${ARCH}" -o /usr/local/bin/starboard \
    && chmod +x /usr/local/bin/starboard

# 3. Setup the workspace
WORKDIR /notebooks

# 4. Run the server
# --host 0.0.0.0 is required so Dokploy/Docker can route traffic to it
EXPOSE 8000
ENTRYPOINT ["starboard", "serve", "--host", "0.0.0.0", "--port", "8000", "."]
