# Stage 1: Builder - Fetches the Pico SDK using Debian Slim
FROM debian:bullseye-slim AS builder

# Install git and certificates
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Perform a shallow clone of the SDK
RUN git clone --depth 1 https://github.com/raspberrypi/pico-sdk.git /pico-sdk && \
    cd /pico-sdk && \
    git submodule update --init --depth 1

# Stage 2: Final Image - Uses Debian Slim and minimal packages
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install only the essential dependencies.
# 'build-essential' is replaced by 'make' and 'libc6-dev' to save space.
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    make \
    libc6-dev \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy the pre-cloned SDK from the builder stage
COPY --from=builder /pico-sdk /pico-sdk

# Variables de entorno para el SDK
ENV PICO_SDK_PATH=/pico-sdk

# Directorio de trabajo
WORKDIR /project

# Comando por defecto
CMD ["/bin/bash"]
