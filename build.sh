#!/bin/bash

set -e # Detener el script si hay algún error

# Configuración
IMAGE_NAME="kevcam7/pico-builder"
PROJECT_DIR=$(pwd)
BUILD_DIR="build"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

# Función para limpiar build
clean_build() {
  if [ -d "$BUILD_DIR" ]; then
    print_warning "Eliminando carpeta build existente..."
    rm -rf "$BUILD_DIR"
  fi
  print_info "Creando carpeta build limpia..."
  mkdir -p "$BUILD_DIR"
}

# Función para verificar si podman/docker está disponible
check_container_runtime() {
  if command -v docker &>/dev/null; then
    CONTAINER_CMD="docker"
  elif command -v podman &>/dev/null; then
    CONTAINER_CMD="podman"
  else
    print_error "No se encontró ni podman ni docker instalado."
    exit 1
  fi
  print_info "Usando: $CONTAINER_CMD"
}

# Función para encontrar archivos .uf2
find_uf2_files() {
  find "$BUILD_DIR" -name "*.uf2" -type f
}

# Mostrar ayuda
show_help() {
  cat <<EOF
Uso: $0 [OPCIONES]

Opciones:
  -c, --clean       Limpiar build antes de compilar
  -r, --rebuild     Forzar recompilación completa (limpia y compila)
  -h, --help        Mostrar esta ayuda
  -v, --verbose     Modo verbose (muestra más detalles)

Ejemplos:
  $0                # Compilación incremental
  $0 --clean        # Limpiar y compilar desde cero
  $0 -r             # Forzar rebuild completo

EOF
}

# Parsear argumentos
CLEAN_BUILD=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
  -c | --clean)
    CLEAN_BUILD=true
    shift
    ;;
  -r | --rebuild)
    CLEAN_BUILD=true
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  -v | --verbose)
    VERBOSE=true
    shift
    ;;
  *)
    print_error "Opción desconocida: $1"
    show_help
    exit 1
    ;;
  esac
done

# Banner
echo "════════════════════════════════════════"
echo "  🔧 Raspberry Pi Pico Builder"
echo "════════════════════════════════════════"
echo ""

# Verificar runtime de contenedores
check_container_runtime

# Limpiar si se solicitó
if [ "$CLEAN_BUILD" = true ]; then
  clean_build
else
  # Crear carpeta build si no existe
  if [ ! -d "$BUILD_DIR" ]; then
    print_info "Creando carpeta build..."
    mkdir -p "$BUILD_DIR"
  else
    print_info "Usando carpeta build existente (compilación incremental)"
  fi
fi

# Opciones adicionales para verbose
VERBOSE_FLAG=""
if [ "$VERBOSE" = true ]; then
  VERBOSE_FLAG="VERBOSE=1"
fi

print_info "Iniciando compilación en contenedor..."
echo ""

# Ejecutar compilación
$CONTAINER_CMD run --rm -it \
  -v "$PROJECT_DIR":/project \
  -u "$(id -u):$(id -g)" \
  "$IMAGE_NAME" \
  /bin/bash -c "cd build && cmake .. && make $VERBOSE_FLAG"

echo ""
echo "════════════════════════════════════════"

# Verificar resultado
UF2_FILES=$(find_uf2_files)

if [ -n "$UF2_FILES" ]; then
  print_success "¡Compilación exitosa!"
  echo ""
  print_info "Archivos .uf2 generados:"
  while IFS= read -r file; do
    echo "  📦 $(basename "$file")"
    echo "     Ruta: $file"
    echo "     Tamaño: $(du -h "$file" | cut -f1)"
  done <<<"$UF2_FILES"
  echo ""
  print_info "Para flashear tu Pico:"
  print_info "1. Mantén presionado BOOTSEL mientras conectas la Pico"
  print_info "2. Arrastra el archivo .uf2 a la unidad RPI-RP2"
else
  print_error "No se generó ningún archivo .uf2"
  print_warning "Revisa los errores de compilación arriba"
  exit 1
fi

echo "════════════════════════════════════════"
