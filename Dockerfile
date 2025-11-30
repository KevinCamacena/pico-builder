# Stage 1: Builder - Fetches the Pico SDK
FROM ubuntu:22.04 AS builder

# Install git only to clone the SDK
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Perform a shallow clone of the SDK and its submodules to save space
RUN git clone --depth 1 https://github.com/raspberrypi/pico-sdk.git /pico-sdk && \
    cd /pico-sdk && \
    git submodule update --init --depth 1


# Stage 2: Final Image - Contains only the necessary toolchain and the SDK
FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Install only the essential dependencies for compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    build-essential \
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
