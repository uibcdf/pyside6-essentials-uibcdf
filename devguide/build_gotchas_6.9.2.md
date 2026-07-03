# Build gotchas — 6.9.2

Lessons learned building `pyside6-essentials-uibcdf` `_4`. Read this before
touching the recipe or opening a 6.10.x line. (These can be folded into
`bootstrap_6.9.2.md` if preferred.)

## 1. Build a fixed module set with `-DMODULES` (do not auto-detect)

PySide's build, without `-DMODULES`, builds **every Qt module it can find**. That
is fragile: if the conda environment you run `conda build` from happens to have an
extra Qt package installed, PySide picks it up and tries to build bindings for it.

That is exactly what bit us: the active env had `qt6-webengine-uibcdf` installed
(for standalone-Qt testing), essentials found it, and the build failed at:

```
CMake Error: Target "QtWebEngineCore" links to Qt::WebEngineCore
  but the target was not found.
```

WebEngine bindings belong to `pyside6-addons-uibcdf`, not essentials. The fix is
the same pattern addons already uses: **whitelist the module set to build** via
`-DMODULES='...'`. Then it does not matter what is found — only what is listed is
built. Recipe:

```
-DMODULES='Core;Gui;Widgets;PrintSupport;Sql;Network;Test;Concurrent;DBus;Designer;Xml;Help;OpenGL;OpenGLWidgets;Qml;Quick;QuickControls2;QuickTest;QuickWidgets;Svg;SvgWidgets;UiTools;WebChannel;WebSockets'
```

## 2. `-DMODULES` order must be dependency order (Core first)

The list order drives PySide's inter-module include setup. An alphabetical list
put `Concurrent` before `Core`, and the QtConcurrent wrapper then failed to find
the QtCore-generated header:

```
fatal error: pyside6_qtcore_python.h: No such file or directory
```

List modules in dependency order — `Core` first, then `Gui`, `Widgets`, ... — the
order PySide auto-detects them in when `-DMODULES` is absent.

## 3. `ExampleIcons` cannot go in `-DMODULES`

`QtExampleIcons` is a PySide-internal module with **no `Qt6ExampleIcons` component**
in `qt6-main`. Auto-detect builds it silently, but an explicit `-DMODULES` entry
makes PySide require the (non-existent) component and the configure fails with
`Qt6ExampleIcons_DIR-NOTFOUND`. It is dropped from the list, so `_4` ships **24
modules** (no `QtExampleIcons`, a trivial example-icons helper) vs `_3`'s 25.

## 4. Flags that did NOT fix the leak (don't treat them as load-bearing)

While debugging we added, to the `cmake` configure call:

```
-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF
-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
```

Neither stopped the WebEngine leak — PySide resolves each module's `_DIR` in a way
that escapes the normal `find_package` search these flags constrain. They are kept
only as **standard conda-build hygiene** (they prevent *other* find_package leaks
into the isolated prefix). The actual fix is `-DMODULES` (sections 1–2).

They were **removed from `shiboken6-uibcdf`**: shiboken is the binding generator,
does not build Qt module bindings, and never had this problem, so the flags were
pure noise there.

## 5. Build from a clean-ish env

The leak only surfaced because the build env had `qt6-webengine-uibcdf` installed.
`_3` built fine earlier because that env did not yet have it. `-DMODULES` makes the
build robust regardless, but as a rule prefer running `conda build` from an env
that does not have the family's own Qt packages installed.
