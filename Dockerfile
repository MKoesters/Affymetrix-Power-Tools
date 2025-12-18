# Dockerfile for Affymetrix Power Tools (APT)
# Supports x86_64 architecture for Apple Silicon compatibility

FROM --platform=linux/amd64 ubuntu:22.04

# Metadata labels
LABEL org.opencontainers.image.title="Affymetrix Power Tools" \
      org.opencontainers.image.description="Docker image for Affymetrix Power Tools 2.12.0 for microarray data analysis" \
      org.opencontainers.image.version="2.12.0" \
      org.opencontainers.image.vendor="Community" \
      org.opencontainers.image.licenses="ThermoFisher" \
      org.opencontainers.image.source="https://github.com/MKoesters/Affymetrix-Power-Tools"

# Build arguments
ARG APT_VERSION=2.12.0
ARG APT_DOWNLOAD_URL=https://downloads.thermofisher.com/APT/APT_2.12.0/apt_2.12.0_linux_64_x86_binaries.zip

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install APT
WORKDIR /opt
RUN wget -q "${APT_DOWNLOAD_URL}" -O apt.zip && \
    unzip -q apt.zip && \
    rm apt.zip && \
    mkdir apt && \
    mv bin apt && \
    chmod -R 755 /opt/apt/bin

# Validate installation
RUN test -f /opt/apt/bin/apt-cel-convert || (echo "APT installation failed: apt-cel-convert not found" && exit 1) && \
    test -f /opt/apt/bin/apt-probeset-summarize || (echo "APT installation failed: apt-probeset-summarize not found" && exit 1) && \
    test -f /opt/apt/bin/apt-probeset-genotype || (echo "APT installation failed: apt-probeset-genotype not found" && exit 1) && \
    echo "APT ${APT_VERSION} installed and validated successfully"

# Add APT binaries to PATH
ENV PATH="/opt/apt/bin:${PATH}"

# Create working directory for data
WORKDIR /data

# Set apt-cel-convert as default entrypoint
ENTRYPOINT ["apt-cel-convert"]

# Default help command
CMD ["--help"]
