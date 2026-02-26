#!/bin/bash
set -e

SRC_DIR="src"
BUILD_ROOT="build"
PYTHON_BIN="python3.14"

mkdir -p "$BUILD_ROOT"

for func in "$SRC_DIR"/*; do
  if [ -d "$func" ]; then
    FUNC_NAME=$(basename "$func")
    echo "Empaquetando $FUNC_NAME..."

    WORK_DIR="$BUILD_ROOT/$FUNC_NAME"
    CACHE_DIR="$WORK_DIR/deps"
    PACKAGE_DIR="$WORK_DIR/package"

    mkdir -p "$CACHE_DIR"
    mkdir -p "$PACKAGE_DIR"

    REQ_FILE="$func/requirements.txt"
    HASH_FILE="$CACHE_DIR/requirements.hash"

    if [ -f "$REQ_FILE" ]; then
      NEW_HASH=$(sha256sum "$REQ_FILE" | awk '{print $1}')
    else
      NEW_HASH="no_requirements"
    fi

    OLD_HASH=""
    if [ -f "$HASH_FILE" ]; then
      OLD_HASH=$(cat "$HASH_FILE")
    fi

    if [ "$NEW_HASH" != "$OLD_HASH" ]; then
      echo "Dependencias cambiaron. Reinstalando..."

      rm -rf "$CACHE_DIR"/*
      $PYTHON_BIN -m venv "$WORK_DIR/venv"
      source "$WORK_DIR/venv/bin/activate"

      pip install --upgrade pip

      if [ -f "$REQ_FILE" ]; then
        pip install -r "$REQ_FILE"
      fi

      SITE_PACKAGES=$(python -c "import site; print(site.getsitepackages()[0])")
      cp -r "$SITE_PACKAGES"/* "$CACHE_DIR"/

      deactivate
      rm -rf "$WORK_DIR/venv"

      echo "$NEW_HASH" > "$HASH_FILE"
    else
      echo "Dependencias sin cambios. Reutilizando cache."
    fi

    rm -rf "$PACKAGE_DIR"/*
    cp -r "$CACHE_DIR"/* "$PACKAGE_DIR"/ 2>/dev/null || true
    cp "$func/lambda_function.py" "$PACKAGE_DIR"/

    cd "$PACKAGE_DIR"
    zip -r9 "../../../$FUNC_NAME.zip" .
    cd - >/dev/null

    echo "$FUNC_NAME.zip listo"
  fi
done

echo "Empaquetado completo."
