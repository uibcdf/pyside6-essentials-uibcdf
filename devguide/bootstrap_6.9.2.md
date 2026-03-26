# Bootstrap 6.9.2

## Scope

This repo currently tracks the first Linux/Python 3.13 experimental UIBCDF line
for `PySide6_Essentials` version `6.9.2`.

The repo is still at scaffold stage. The source import and recipe refinement are
still pending, but the local rules for doing them are recorded here.

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

Current local manifests copied into this repo should come from:

- `molsysviewer/sandbox/qt_for_python_uibcdf_experiment/manifests/pyside6_essentials.files.txt`
- `molsysviewer/sandbox/qt_for_python_uibcdf_experiment/manifests/pyside6_essentials.runtime.txt`

At the time this note was written, those manifests have not yet been copied
into this repo. That is one of the first next steps.

## Current Packaging Reading

`PySide6_Essentials` appears to carry the large base runtime payload for the
Qt-for-Python family, including a self-aligned Qt base runtime under:

- `PySide6/Qt`

This matters because the family should not be modeled naively as a tiny Python
layer on top of `qt6-main` from conda-forge.

## Planned First Packaging Decision

The first pass should mirror the `shiboken6-uibcdf` approach:

- start manifest-driven
- copy the validated `PySide6_Essentials` boundary into `$SP_DIR`
- use that step to prove the package boundary before attempting a more
  source-build-led recipe

## Expected Dependency Position

`pyside6-essentials-uibcdf` depends on:

- `shiboken6-uibcdf`

And is itself a prerequisite for:

- `pyside6-addons-uibcdf`

## First Implementation Checklist

1. copy the validated manifests into `manifests/`
2. vendor the relevant upstream code from `sources/pyside6`
3. define the minimal boundary for the `Essentials` slice only
4. write a manifest-driven `build.sh`
5. add minimal file/import tests to `meta.yaml`
6. run a temporary `site-packages` smoke check
7. only then attempt a true `conda build`

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
