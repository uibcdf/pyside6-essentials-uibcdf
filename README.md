# pyside6-essentials-uibcdf

Experimental UIBCDF packaging repo for the second member of the provisional
Qt-for-Python standalone family.

Current scope:

- Linux
- Python 3.13
- version family: 6.9.2

Role in the family:

- depends on shiboken6-uibcdf
- carries the large base Qt-for-Python runtime boundary
- appears to bring its own Qt base runtime under PySide6/Qt

Current source of truth:

- validated environment:
  /home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike
- local manifests staged in molsysviewer:
  - sandbox/qt_for_python_uibcdf_experiment/manifests/pyside6_essentials.files.txt
  - sandbox/qt_for_python_uibcdf_experiment/manifests/pyside6_essentials.runtime.txt
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
- `devtools/conda-build/build.sh` copies the validated `PySide6_Essentials` boundary
  from the known-good environment into `$SP_DIR`
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
