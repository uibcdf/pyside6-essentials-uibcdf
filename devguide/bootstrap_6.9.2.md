# Bootstrap 6.9.2

## Scope

This repo currently tracks the first Linux/Python 3.13 experimental UIBCDF line
for `PySide6_Essentials` version `6.9.2`.

The repo is no longer only a scaffold. It now contains:

- a first manifest-driven recipe attempt
- a vendored upstream subset for the Essentials line
- a first self-contained packaging boundary under `package_boundary/`

## Why This Repo Exists

The standalone investigation showed that the working Qt-for-Python family is
not well modeled as a tiny extension over the current conda-forge stack.

The provisional UIBCDF family is instead:

- `shiboken6-uibcdf`
- `pyside6-essentials-uibcdf`
- `pyside6-addons-uibcdf`

This repo owns the `PySide6_Essentials` slice.

## Expected Upstream Source

The upstream code should be taken from:

- `/home/diego/repos@others/pyside-setup`

Relevant upstream subtree for this repo:

- `/home/diego/repos@others/pyside-setup/sources/pyside6`

This repo is expected to vendor only the part of that tree needed for the
`PySide6_Essentials` boundary and build flow.

## Where The Packaging Boundary Came From

The initial boundary reading came from the validated environment:

- `/home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike`

Current local manifests copied into this repo are:

- `manifests/pyside6_essentials.files.txt`
- `manifests/pyside6_essentials.runtime.txt`

The first self-contained packaging boundary was then copied into this repo
under:

- `package_boundary/site-packages`

## Current Packaging Reading

`PySide6_Essentials` appears to carry the large base runtime payload for the
Qt-for-Python family, including a self-aligned Qt base runtime under:

- `PySide6/Qt`

This matters because the family should not be modeled naively as a tiny Python
layer on top of `qt6-main` from conda-forge.

## Planned First Packaging Decision

The first pass mirrors the `shiboken6-uibcdf` approach:

- start manifest-driven
- copy the vendored `PySide6_Essentials` boundary from
  `package_boundary/site-packages` into `$SP_DIR` by default
- still allow overriding the source boundary with:
  - `PYSIDE6_ESSENTIALS_UIBCDF_SOURCE_PREFIX`
- use that step to prove the package boundary before attempting a more
  source-build-led recipe

## Expected Dependency Position

`pyside6-essentials-uibcdf` depends on:

- `shiboken6-uibcdf`

And is itself a prerequisite for:

- `pyside6-addons-uibcdf`

## First Implementation Checklist

1. validate the repo-local boundary still matches the intended 6.9.2 slice
2. keep the vendored upstream subset aligned with the chosen family version
3. keep the deferred `bin/`, `PySide6/scripts/*`, and `PySide6/support/*`
   decisions explicit until they are reintroduced deliberately
4. run a temporary `site-packages` smoke check
5. only then attempt a true `conda build`

## How To Open A Future 6.10.x Line

1. validate a coherent 6.10.x environment first
2. regenerate `PySide6_Essentials` manifests from that environment
3. vendor the matching `sources/pyside6` code
4. update this repo's version line and recipe pins
5. re-run the same manifest-driven smoke path before any release attempt

## Things To Keep Stable

- do not mix `Essentials` payloads across family versions
- keep this repo aligned with `shiboken6-uibcdf` and `pyside6-addons-uibcdf`
- keep this note updated whenever the source extraction rule changes

Current upstream subset staged in this repo:

- root build files from `sources/pyside6`
- `cmake`
- `libpyside`
- `libpysideqml`
- `libpysideremoteobjects`
- `plugins`
- `PySide6/glue`, `PySide6/support`, `PySide6/templates`
- runtime-backed module dirs currently imported for the Essentials boundary:
  - `QtConcurrent`
  - `QtCore`
  - `QtDBus`
  - `QtDesigner`
  - `QtGui`
  - `QtHelp`
  - `QtNetwork`
  - `QtOpenGL`
  - `QtOpenGLWidgets`
  - `QtPrintSupport`
  - `QtQml`
  - `QtQuick`
  - `QtQuickControls2`
  - `QtQuickTest`
  - `QtQuickWidgets`
  - `QtSql`
  - `QtSvg`
  - `QtSvgWidgets`
  - `QtTest`
  - `QtUiTools`
  - `QtWidgets`
  - `QtXml`

## Pause Checkpoint

Current active state before pausing:

- The repo is already on the clean `6.9.2` source line.
- The `_uibcdf` namespace split is already in place.
- `build.sh` now also includes a post-install relocation step intended to move any canonical
  `site-packages/PySide6/...` install tree into `site-packages/PySide6_uibcdf/...`.
- `build.sh` now exports `C_INCLUDE_PATH` and `CPLUS_INCLUDE_PATH` with `${PREFIX}/include` so the
  OpenGL headers from `libgl-devel` are visible to `shiboken`.
- `meta.yaml` now asserts that `site-packages/PySide6/Qt` should not remain after installation.
- `QtCore` now carries the `6.9.2` compatibility cut for `QDirListing`:
  - `QDirListing` and `QDirListingIterator` are marked `generate="no"`
  - their generated wrapper entries were removed from `PySide6/QtCore/CMakeLists.txt`
- `QtCore` / `QtNetwork` / `QtGui` / `QtWidgets` already carry multiple deliberate compatibility cuts for
  this standalone-oriented line, including:
  - `QStringEncoder`, `QStringDecoder`, `QStringConverter*`, `QTextStream` encoding helpers
  - `QLocalSocket`, `QLocalServer`
  - `QTextOption` and its direct dependent overloads
  - `QFileDialog`, `QFileSystemModel`, `QMessageBox`, `QPinchGesture`, `QTreeWidgetItemIterator`
- `QtQml` also now carries the first direct cut in this line:
  - `QQmlImageProviderBase` removed from generation
  - `QQmlEngine::addImageProvider(...)` removed
  - `QQmlEngine::imageProvider(...)` removed

Latest build reading:

- the build already gets well past `QtWidgets`
- `QQmlImageProviderBase` is no longer the active blocker
- the current hard failure is now in `QtQuick`
- exact failing surfaces:
  - `QQuickItem::flags() const`
  - `QQuickItem::setFlags(...)`
  - `QQuickRenderTarget::fromOpenGLTexture(...)` with flags
- exact pattern:
  - generated wrappers still use `QFlags<QCommandLineOption::Flag>`
  - Qt expects `QQuickItem::Flags` / `QQuickRenderTarget::Flags`

Exact next task:

1. patch `QtQuick` for this `6.9.2` line:
   - remove `QQuickItem::flags() const`
   - remove `QQuickItem::setFlags(...)`
   - remove the problematic `QQuickRenderTarget::fromOpenGLTexture(...)` flags overload
2. rerun:
   - `conda build /home/diego/repos@uibcdf/pyside6-essentials-uibcdf/devtools/conda-build`
3. only after `Essentials` closes again:
   - resume `pyside6-addons-uibcdf`

What to check first when resuming:

1. whether the next failure remains in `QtQuick` or moves further down the build
2. whether the rebuilt package still installs the Qt runtime under `PySide6_uibcdf/Qt/...`
3. only after `Essentials` closes again, re-open `pyside6-addons-uibcdf`
