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

## Versioning and Build Numbers

The `version` field in `meta.yaml` always tracks the upstream Qt-for-Python
version (e.g. `6.9.2`). It changes only when the upstream version changes.

The `build.number` field is the mechanism for shipping corrections to the same
upstream version:

- **Bug in the recipe, in patches, or in the C++/typesystem sources** (e.g. a
  new RHI suppression, a typesystem fix): increment `build.number` by 1, keep
  `version` as-is.
- **New upstream version** (e.g. 6.10.x): reset `build.number` to 0 and update
  `version`.

`conda update` / `mamba update` resolves packages by version first, then by
build number within the same version, so users will automatically receive the
corrected build when they run an update.

All three packages in the family (`shiboken6-uibcdf`, `pyside6-essentials-uibcdf`,
`pyside6-addons-uibcdf`) should be released together with the same build number
whenever a correction touches the shared runtime (e.g. a `libshiboken` patch
that affects all three).

Upload to the `uibcdf` channel with:

```bash
anaconda upload <path-to-package.conda> --user uibcdf --channel uibcdf
```

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

## Applied fixes (2026-03-31 / 2026-04-01)

The `QtQuick` flag-type bug is pervasive. Two distinct root causes confirmed:

**Root cause A** — missing base class enum:
shiboken generates `QFlags<QCommandLineOption::Flag>` when the base class defining
the flag typedef is `generate="no"` without enum declarations (`QQmlImageProviderBase`).
Fix: `generate="no"` on the subclass so no C++ wrapper is emitted at all.
Also remove from `CMakeLists.txt`.

**Root cause B** — same-named enums across classes:
shiboken confuses `QFlags<ClassA::SomeName>` with `QFlags<ClassB::SomeName>` when
two classes declare enums with the same short name (e.g. `Flag`, `TextureCoordinatesTransformFlag`).
Fix: `remove="all"` on the affected methods with regex signatures.

**Key lesson**: `remove="all"` removes the Python binding and the conversion code
in the `.cpp` wrapper but does NOT prevent C++ virtual override generation in the
shell header. For virtual methods use `generate="no"` on the class. For non-virtual
methods `remove="all"` is sufficient.

Surfaces fixed in `typesystem_quick.xml`:

- `QQuickImageProvider` — `generate="no"` (Root A + virtual `flags()`)
- `QQuickAsyncImageProvider` — `generate="no"` + removed from `CMakeLists.txt` (Root A)
- `QQuickItem::flags()const`, `setFlags(...)` — `remove="all"` (Root B: `Flag`)
- `QQuickRenderTarget::fromOpenGLTexture(...,Flags)` — `remove="all"` (Root B)
- `QSGRenderNode::flags()const` — `remove="all"` (Root B: `RenderingFlag`)
- `QSGMaterial::flags()const`, `setFlag(...)`, `setFlags(...)` — `remove="all"` (Root B: `Flag`)
- `QSGMaterialShader::flags()const`, `setFlag(...)`, `setFlags(...)` — `remove="all"` (Root B: `Flag`)
- `QSGNode::flags()const`, `setFlag(...)`, `setFlags(...)` — `remove="all"` (Root B: `Flag`)
- `QSGImageNode::textureCoordinatesTransform*` — `remove="all"` (Root B: `TextureCoordinatesTransformFlag`)
- `QSGSimpleTextureNode::textureCoordinatesTransform*` — `remove="all"` (Root B: same)

**Next step**: run `conda build` with `CPU_COUNT=14`. If a new flag-type error appears:
1. Search log for `cannot convert 'QFlags<QCommandLineOption::Flag>'` or `invalid covariant return type`.
2. Identify class and method. If method is virtual → `generate="no"` on class + remove from CMakeLists. If non-virtual → `remove="all"` with regex signature.
3. Only after Essentials closes: resume `pyside6-addons-uibcdf`.

## Runtime crash patterns (2026-04-01)

These were discovered after the compilation errors above were resolved. They
manifest at the `python -c "import PySide6_uibcdf.QtCore"` test step.

### Pattern: `AddTypeCreationFunction` crash with nested type of `generate="no"` parent

**Symptom (build 15):** Segfault inside `Shiboken::Module::AddTypeCreationFunction`
when registering a nested type whose parent class is `generate="no"`.

**Example:** `QDirListing` is `generate="no"` (no Python type exists for it).
Marking `QDirListing::DirEntry` as generated (but not `QDirListing`) caused
shiboken to emit `init_QDirListing_DirEntry` and register it via:
```c++
AddTypeCreationFunction(module, "QDirListing", init_QDirListing_DirEntry, "QDirListing.DirEntry");
```
This crashes because "QDirListing" has no Python type in the module.

**Fix:** Mark the nested type `generate="no"` too:
```xml
<object-type name="QDirListing" since="6.8" generate="no">
    <value-type name="DirEntry" generate="no"/>
    ...
</object-type>
```
The corresponding `qdirlisting_direntry_wrapper.cpp` must NOT be in CMakeLists.

**Rule:** If a parent class is `generate="no"`, ALL its nested types must also
be `generate="no"` — or the generated module init will crash.

### Pattern: `PyTuple_Pack(n=1, NULL)` crash — lazy base class initialization fails

**Symptom (build 16):** Segfault in `PyTuple_Pack` during `PyInit_QtCore`:
```
PyTuple_Pack(n=1)           ← crash: arg is NULL
init_QOperatingSystemVersion  ← calls PyTuple_Pack(1, Module::get(base_IDX))
libshiboken (lazy incarnate)
PyObject_GetAttrString        ← triggers lazy init of QOperatingSystemVersion
init_QOperatingSystemVersionStaticFields
PyInit_QtCore
```

**Root cause:** `Shiboken::Module::get(typeStruct)` has a slow path for lazy
type resolution. It extracts the module name from `typeStruct.fullName` (e.g.
`"PySide6.QtCore.QOperatingSystemVersionBase"`) and looks it up in `sys.modules`.

The `shiboken6-uibcdf` version of this code was patched to check for the
`"PySide6_uibcdf."` prefix. But the **generated** fullName strings (from
typesystem XML `package="PySide6.QtCore"`) still use `"PySide6."`. So the code
computed `modName = "PySide6"`, found nothing in sys.modules (our package is
`"PySide6_uibcdf"`), returned NULL, and the NULL was passed to `PyTuple_Pack`.

**Fix:** In `shiboken6-uibcdf/libshiboken/sbkmodule.cpp`, add a remap before the
`usePySide` check (see shiboken6-uibcdf devguide for the exact patch). This fix
is in `shiboken6-uibcdf`, not in this repo. Rebuilding shiboken6-uibcdf and then
pyside6-essentials-uibcdf is required.

**Diagnostic commands:**
```bash
# Reproduce the crash:
python -c "import PySide6_uibcdf.QtCore"

# Get backtrace:
gdb --batch -ex run -ex bt --args python -c "import PySide6_uibcdf.QtCore"

# Find the crashed address in the .so (from info sharedlibrary base + frame offset):
# Then disassemble to find the fullName string:
# x/s <address-of-string>
```

**When upgrading to 6.10.x:** Re-check that shiboken6-uibcdf's `Module::get`
still has the `"PySide6."` → `"PySide6_uibcdf."` remap, especially if upstream
changed `Module::get`. Also verify there are no new nested-type crashes by
searching `conda build` log for `AddTypeCreationFunction` errors.

### Pattern: wrong test paths in meta.yaml

After a successful build, if test commands like `test -f "$SP_DIR/PySide6_uibcdf/Qt/lib/libQt6Core.so.6"` fail, check the actual install layout. In 6.9.2 the Qt libs land in `$PREFIX/lib/`, not under `$SP_DIR/PySide6_uibcdf/Qt/lib/`. Correct paths:
```yaml
- test -f "$SP_DIR/PySide6_uibcdf/QtCore.abi3.so"
- test -f "$PREFIX/lib/libpyside6.abi3.so.6.9"
- test -f "$PREFIX/lib/libQt6Core.so.6"
```

## Reflexión arquitectónica: ¿essentials/addons o build-what-you-need?

Esta sección documenta una reflexión surgida durante el desarrollo de 6.9.2 y relevante para el diseño de futuros stacks.

### El problema de la división essentials/addons heredada

La división `pyside6-essentials-uibcdf` / `pyside6-addons-uibcdf` replica la estructura de upstream (Qt Company). Esto tiene lógica si el objetivo es cubrir el mismo territorio que PySide6 estándar. Pero el objetivo real del stack UIBCDF es mucho más concreto:

**molsysviewer standalone necesita exclusivamente:**

| Módulo Python | Para qué |
|---|---|
| `PySide6_uibcdf.QtCore` | Señales, QTimer, QThread |
| `PySide6_uibcdf.QtGui` | Base de QWidget, sin RHI |
| `PySide6_uibcdf.QtWidgets` | QApplication, QMainWindow |
| `PySide6_uibcdf.QtNetwork` | Requests internos de WebEngine |
| `PySide6_uibcdf.QtWebChannel` | Puente Python↔JS con Mol* |
| `PySide6_uibcdf.QtWebEngineCore` | Motor de rendering HTML/WebGL |
| `PySide6_uibcdf.QtWebEngineWidgets` | QWebEngineView |

Mol* renderiza con WebGL dentro del motor del browser; el GPU rendering lo gestiona Chromium/Qt WebEngine internamente, **no** los bindings Python de QRhi, QSG, QOpenGL, ni QQuick.

### Errores que hubieran desaparecido con un enfoque minimal

Todos los problemas de compilación en la serie de builds de 6.9.2 relacionados con RHI y Qt Quick son de módulos **que molsysviewer no necesita**:

- `QRhiGraphicsPipeline::Flag` vs `QCommandLineOption::Flag` — RHI no necesario
- `SBK_QRhiRenderTarget_IDX` indefinido en `qrhiwidget_wrapper.cpp` — RHI no necesario
- `QQuickRhiItem` / `QQuickRhiItemRenderer` — QtQuick no necesario
- El bloqueador de QtQuick (razón original del fork `pyside6-essentials-uibcdf`) — QtQuick no necesario

El único error que habría persistido es el bug fundamental en `shiboken6-uibcdf` (prefijo `PySide6.` → `PySide6_uibcdf.` en `Module::get`), que es independiente de los módulos que se compilen.

### Alternativa para 6.10.x: un paquete único minimal

En vez de dos paquetes (essentials + addons), un único paquete `pyside6-uibcdf` que solo compila los 7 módulos de la tabla anterior:

**Ventajas:**
- Surface de compilación ~5-6x menor (≈200 targets vs ≈1041)
- Sin errores de shiboken por tipos privados RHI ni QQuick
- Ciclo de debug más rápido
- Alineado exactamente con el caso de uso

**Inconvenientes:**
- Más alejado del packaging estándar de Qt Company
- Si se añaden features que requieran más módulos Qt/Python, hay que reconstruir
- Requiere un recipe propio en vez de derivar de upstream

### Decisión para 6.9.2

Se continúa con el enfoque essentials/addons porque los bugs hard ya están resueltos y quedan pocos builds para terminar. No se justifica rediseñar.

**Para 6.10.x**: evaluar el enfoque minimal antes de empezar. Si molsysviewer standalone sigue necesitando solo los 7 módulos de la tabla, el ahorro en tiempo de compilación y mantenimiento es considerable.

### Pattern: Module::import prefix mismatch (2026-04-02)

**Symptom:** `import PySide6_uibcdf.QtGui` raises:
```
ImportError: could not import module 'PySide6.QtCore'
```
even though `import PySide6_uibcdf.QtCore` works.

**Root cause:** `Shiboken::Module::import(moduleName)` in `shiboken6-uibcdf/libshiboken/sbkmodule.cpp`
is called when a module loads its dependencies. The generated module init passes `"PySide6.QtCore"`.
`Module::import` calls `PyImport_ImportModule("PySide6.QtCore")` — which fails because our
package is `PySide6_uibcdf.QtCore`. This is a separate function from `Module::get`; both needed
the same `"PySide6." → "PySide6_uibcdf."` remap.

**Fix:** In `shiboken6-uibcdf/libshiboken/sbkmodule.cpp`, add the same prefix remap to
`Module::import` as was added to `Module::get`. See shiboken6-uibcdf devguide (commit 4e60fb6).
Rebuild shiboken6-uibcdf, then rebuild pyside6-essentials-uibcdf.

### Pattern: RHI types causing compilation failures in QtGui/QtWidgets/QtQuick

**Symptom:** Build fails with errors like:
```
'SBK_QRhiRenderTarget_IDX' was not declared in this scope
'SBK_QRhiTexture_IDX' was not declared in this scope
conversion from 'QFlags<QRhiGraphicsPipeline::Flag>' to non-scalar type 'QFlags<QCommandLineOption::Flag>'
```

**Root cause:** Qt 6.6+ added private RHI types to the public API typesystem XML. Shiboken generates
broken wrappers for these types due to enum type resolution conflicts (multiple classes named `Flag`
get confused). These types are not needed for molsysviewer.

**Fix (applied in 6.9.2):**
1. Add `generate="no"` to ALL types in `PySide6/QtGui/typesystem_gui_rhi.xml`
2. Mark `QRhiWidget` (QtWidgets) and `QQuickRhiItem`/`QQuickRhiItemRenderer` (QtQuick) as `generate="no"` and remove their wrapper .cpp from CMakeLists
3. Add `<modify-function ... remove="all"/>` for methods in `QQuickWindow`, `QQuickRenderControl`, `QQuickRenderTarget`, `QSGMaterialShader::RenderState`, `QSGMaterialShader::GraphicsPipelineState`, `QSGRenderNode`, `QSGTexture`, `QQuickGraphicsDevice` that return or accept RHI pointer types

**For 6.10.x:** Qt may add new RHI-dependent methods to existing classes. If build fails with
`SBK_QRhi*_IDX undeclared`, find the class and add `<modify-function ... remove="all"/>` for
the affected method.

## How to port to 6.10.x

When opening a 6.10.x line, use this checklist in order:

1. **shiboken6-uibcdf first** — rebuild and test before touching essentials.
   Confirm **both** `Module::get` AND `Module::import` remaps are still present
   in `libshiboken/sbkmodule.cpp`.

2. **Check flag-type bugs again** — they depend on enum naming in Qt headers.
   New Qt versions may add or rename enums. Use the Root A / Root B diagnostic
   above to fix any new occurrences.

3. **Check nested `generate="no"` types** — Qt may add new nested types inside
   `generate="no"` parent classes. If `conda build` crashes at AddTypeCreationFunction,
   apply the nested-type fix.

4. **Check RHI spillover** — Qt may add new methods to QtQuick/QtWidgets classes
   that return RHI types. Look for `SBK_QRhi*_IDX undeclared` errors and add
   `<modify-function ... remove="all"/>` for the affected methods.

5. **Check same-name enum confusion** — shiboken resolves short enum names by
   searching across all registered types. When two classes share an enum name,
   shiboken may pick the wrong one across ALL methods of the class, making
   `remove="all"` on individual methods insufficient. The only viable fix is
   `generate="no"` on the entire class.

   Known affected classes in 6.9.2:
   - `QFileDialog`: `Option` confused with `QAbstractFileIconProvider::Option`
   - `QMessageBox`: `Option` confused with `QAbstractFileIconProvider::Option`,
     and `StandardButton` confused with `QDialogButtonBox::StandardButton`

   Symptom pattern:
   ```
   error: cannot convert 'QFlags<QAbstractFileIconProvider::Option>' to 'QFlags<QFileDialog::Option>'
   error: cannot convert 'QFlags<QDialogButtonBox::StandardButton>' to 'QFlags<QMessageBox::StandardButton>'
   ```

   When upgrading to 6.10.x: check whether new classes with same-named enums
   appear, and whether Qt resolves the upstream ambiguity (upstream shiboken
   has an `identify-by-name` mechanism that may help).

6. **Run gdb on failed imports** — the `PyTuple_Pack(n=1)` crash pattern is
   always caused by `Module::get` returning NULL. The fix is always in shiboken6-uibcdf
   unless a different root cause is found.

7. **CPU_COUNT=14** — keep this limit to avoid OOM kills during compilation.
   20+ CPUs × ~2GB per shiboken wrapper = exceeds 32GB RAM + swap.
