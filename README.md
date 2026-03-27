# pyside6-essentials-uibcdf

Experimental UIBCDF packaging repo for the second member of the provisional
Qt-for-Python standalone family.

Current scope:

- Linux
- Python 3.13
- target source-build family: 6.10.2

Note:

- the repo still contains bootstrap boundary assets derived from the earlier
  6.9.2 spike environment
- those assets are now historical scaffolding, not the authoritative version
  target for the line we are opening

Role in the family:

- depends on shiboken6-uibcdf
- carries the large base Qt-for-Python runtime boundary
- appears to bring its own Qt base runtime under PySide6/Qt

Current source of truth:

- local manifests copied into this repo:
  - manifests/pyside6_essentials.files.txt
  - manifests/pyside6_essentials.runtime.txt
- first self-contained packaging boundary staged in this repo:
  - package_boundary/site-packages
- original validated environment used to derive that first boundary:
  /home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike
- upstream codebase reference:
  - ~/repos@others/pyside-setup

First-pass success criteria:

1. package the PySide6_Essentials wheel boundary in conda form
2. expose:
   - PySide6/libpyside6.abi3.so.6.9
   - PySide6/libpyside6qml.abi3.so.6.9
   - the aligned Qt base runtime under PySide6/Qt
3. remain explicitly experimental until the full family installs cleanly

Current packaging approach:

- first pass is manifest-driven rather than source-build-driven
- the current first-pass boundary is intentionally limited to the Python/runtime
  payload staged under `site-packages`
- wrapper commands under `bin/` are present in the original wheel manifest but
  are deferred until the core package boundary is proven
- `devtools/conda-build/build.sh` copies the vendored `PySide6_Essentials`
  boundary from `package_boundary/site-packages` into `$SP_DIR` by default
- the source environment can be overridden with:
  - `PYSIDE6_ESSENTIALS_UIBCDF_SOURCE_PREFIX`

Current known boundary caveats:

- a small subset of `PySide6/support/*` references is also inconsistent in the
  observed source environment and is likewise deferred in this first pass
- the upstream wheel manifest includes wrapper commands under `bin/` and a few
  `PySide6/scripts/*` references that do not map one-to-one onto the currently
  observed source environment layout
- the first-pass recipe therefore focuses on the core `site-packages` runtime
  boundary needed for imports such as `PySide6.QtCore`
