# Raspberry Pi Pico Builder

A simple Docker-based cross-compilation environment for Raspberry Pi Pico projects.

This project provides a Docker image based on Ubuntu 22.04 with the Raspberry Pi Pico SDK and all necessary toolchains pre-installed. A companion shell script (`build.sh`) is included to simplify the compilation process, allowing you to build Pico projects without installing the toolchain directly on your host machine.

## Prerequisites

You must have one of the following container runtimes installed:
- [Docker](https://www.docker.com/)
- [Podman](https://podman.io/)

## Setup

1.  **Build the Docker Image**

    The `Dockerfile` defines the build environment. Build the image using the following command. The image will be tagged as `kevcam7/pico-builder`.

    ```bash
    docker build -t kevcam7/pico-builder .
    ```
    *(You can replace `docker` with `podman` if you are using it)*

2.  **Add Your Project Files**

    Place your Raspberry Pi Pico source code (e.g., `.c`, `.cpp`, `.h` files) and your `CMakeLists.txt` in the root of this project directory alongside the `build.sh` script.

    A minimal project structure would look like this:
    ```
    .
    ├── CMakeLists.txt
    ├── main.c
    ├── pico_sdk_import.cmake
    ├── build.sh
    ├── Dockerfile
    └── README.md
    ```

## Usage

The `build.sh` script is the easiest way to compile your project. It automatically uses `docker` or `podman` to run the compilation inside the container.

-   **To compile your project:**
    ```bash
    ./build.sh
    ```

-   **To perform a clean build (removes the `build` directory first):**
    ```bash
    ./build.sh --clean
    ```

-   **To see all available options:**
    ```bash
    ./build.sh --help
    ```

### Script Options

```
Uso: ./build.sh [OPCIONES]

Opciones:
  -c, --clean       Limpiar build antes de compilar
  -r, --rebuild     Forzar recompilación completa (limpia y compila)
  -h, --help        Mostrar esta ayuda
  -v, --verbose     Modo verbose (muestra más detalles)
```

## How It Works

The `build.sh` script automates the following steps:
1.  Checks if `docker` or `podman` is available on your system.
2.  Creates a `build` directory for the output files if it doesn't exist.
3.  Runs a new container using the `kevcam7/pico-builder` image.
4.  Mounts your current project directory into the `/project` directory inside the container.
5.  Executes `cmake` and `make` within the container to compile your code.
6.  Upon successful compilation, it finds and lists the generated `.uf2` files, which you can then flash to your Raspberry Pi Pico.

The compiled files, including the final `.uf2` binary, will be located in the `build` directory on your host machine.
