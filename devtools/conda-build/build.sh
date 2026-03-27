#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "${RECIPE_DIR}/../.." && pwd)"
DEFAULT_SOURCE_SITE_PACKAGES="${REPO_ROOT}/package_boundary/site-packages"
SOURCE_SITE_PACKAGES="${PYSIDE6_ESSENTIALS_UIBCDF_SOURCE_PREFIX:-$DEFAULT_SOURCE_SITE_PACKAGES}"
MANIFEST="${REPO_ROOT}/manifests/pyside6_essentials.files.txt"

if [ ! -d "$SOURCE_SITE_PACKAGES" ]; then
    echo "Missing source site-packages: $SOURCE_SITE_PACKAGES" >&2
    exit 1
fi

if [ ! -f "$MANIFEST" ]; then
    echo "Missing manifest: $MANIFEST" >&2
    exit 1
fi

while IFS= read -r relpath; do
    [ -n "$relpath" ] || continue

    case "$relpath" in
        ../../../bin/*)
            continue
            ;;&
        *__pycache__/*|*.pyc)
            continue
            ;;&
    esac

    src="$SOURCE_SITE_PACKAGES/$relpath"
    rewritten_relpath="$relpath"
    rewritten_relpath="${rewritten_relpath/PySide6\//PySide6_uibcdf/}"
    rewritten_relpath="${rewritten_relpath/pyside6_essentials-6.9.2.dist-info/pyside6_essentials_uibcdf-6.9.2.dist-info}"
    dst="$SP_DIR/$rewritten_relpath"

    if [ ! -e "$src" ]; then
        case "$relpath" in
            PySide6/scripts/*)
                echo "Skipping missing script-side manifest entry: $src" >&2
                continue
                ;;&
            PySide6/support/*)
                echo "Skipping missing support-side manifest entry: $src" >&2
                continue
                ;;&
        esac
        echo "Missing manifest entry in source environment: $src" >&2
        exit 1
    fi

    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
done < "$MANIFEST"

init_py="$SP_DIR/PySide6_uibcdf/__init__.py"
if [ -f "$init_py" ]; then
    perl -0pi -e 's/\bshiboken6\b/shiboken6_uibcdf/g' "$init_py"
    perl -0pi -e 's/sys\.modules\["PySide6"\]/sys.modules["PySide6_uibcdf"]/g' "$init_py"
    perl -0pi -e 's/\bPySide6\b/PySide6_uibcdf/g' "$init_py"
fi
