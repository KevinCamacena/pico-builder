FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    cmake \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    build-essential \
    git \
    python3 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clonar el Pico SDK en una ubicación fija
RUN git clone https://github.com/raspberrypi/pico-sdk.git /pico-sdk && \
    cd /pico-sdk && \
    git submodule update --init

# Variables de entorno para el SDK
ENV PICO_SDK_PATH=/pico-sdk

# Directorio de trabajo
WORKDIR /project

# Comando por defecto
CMD ["/bin/bash"]
