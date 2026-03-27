#!/usr/bin/env bash
set -euo pipefail

export LLVM_INSTALL_DIR="${PREFIX}"
export CLANG_INSTALL_DIR="${PREFIX}"

cmake -S "${SRC_DIR}" -B "${SRC_DIR}/build-conda" -G Ninja \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DPYTHON_SITE_PACKAGES="${SP_DIR}" \
    -DBUILD_TESTS=OFF \
    -DDISABLE_PYI=ON

wrapper="${SRC_DIR}/build-conda/.qfp/bin/shiboken_wrapper.sh"
if [ -f "${wrapper}" ]; then
    python - <<PATCH_WRAPPER
from pathlib import Path
p = Path(${wrapper@Q})
text = p.read_text()
needle = "#!/bin/bash\n"
insert = "#!/bin/bash\nexport LLVM_INSTALL_DIR=${PREFIX@Q}\nexport CLANG_INSTALL_DIR=${PREFIX@Q}\n"
if text.startswith(needle) and "LLVM_INSTALL_DIR" not in text:
    text = insert + text[len(needle):]
    p.write_text(text)
PATCH_WRAPPER
fi

cmake --build "${SRC_DIR}/build-conda" --parallel "${CPU_COUNT:-2}"
cmake --install "${SRC_DIR}/build-conda"
