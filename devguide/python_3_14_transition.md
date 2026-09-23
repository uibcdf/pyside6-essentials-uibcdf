# PySide6 Essentials 6.10.1 / Python 3.14 transition

Issue: [`uibcdf/pyside6-essentials-uibcdf#1`](https://github.com/uibcdf/pyside6-essentials-uibcdf/issues/1).
Status: isolated Linux/Python 3.14 candidate built and tested locally; no
release or channel upload.

## Source and package boundary

The branch starts from this repository's 6.9.2 line. The upstream input is
official `pyside-setup` tag `v6.10.1`, peeled commit
`42be1cc7d9973b7da44c048981001b823b329704`, specifically
`sources/pyside6`. Upstream changed 163 files in that subtree between 6.9.2
and 6.10.1. The fork's 6.9.2 source differed from the official baseline in
21 files, 12 of which also changed upstream. The source delta was ported onto
the fork; five patch rejects were resolved by retaining the UIBCDF namespace
and package paths while taking the applicable upstream behavior.

The candidate Conda recipe requires Python 3.14, exact `qt6-main=6.10.1`,
and `shiboken6-uibcdf=6.10.1` from the locally tested candidate. It is a
per-interpreter `py314` package, not an already-proven multi-interpreter
ABI3 release. The unchanged original 6.9.2 checkout contains a pre-existing
edit to its bootstrap guide; this work uses a separate worktree.
The older `6.10.2` branch is not a substitute for this candidate: its recipe
still combines PySide 6.10.2 with Qt 6.9.2 and Python 3.13.

## First build evidence

The initial local Conda build resolved the exact Python/Qt/Shiboken package
combination, configured CMake, generated bindings and compiled through 812
of 1,043 build steps. It failed compiling the QtQuick wrapper for
`QQuickGraphicsDevice::fromRhiAdapter(QRhiAdapter*)`. The fork deliberately
suppresses RHI types, so that new Qt 6.10 method had no generated argument
type. The method is now excluded from the binding beside the already
excluded `fromRhi(QRhi*)`. The source and Conda's copied build tree were
patched for an incremental diagnosis. The corrected Conda build then
completed all 1,043 steps and its package tests passed.

An out-of-band Ninja retry did not reproduce the complete Conda generator
environment and failed earlier while parsing types. It is not evidence that
the corrected source fails or passes; the completed Conda build settled that
question for Linux/Python 3.14.

## Final local package evidence

The package recipe now carries `devtools/smoke_python_314.py` into its Conda
test environment. It checks exact Qt and Shiboken versions, QtCore, QtGui,
QtNetwork, QtQml, QtQuick, and QtWidgets imports and representative behavior,
signal delivery, Shiboken object validity, and an offscreen application event
loop. The rebuilt artifact passed every recipe test, including this script.

The locally built candidate is
`pyside6-essentials-uibcdf-6.10.1-py314h3fd9d12_0.conda` for `linux-64`,
with SHA-256
`d0fcd34214d377e2ecada42608cabbc9d7c7c390af9196e9261ee24e5453bdf5`.
An independent offline Conda environment selected this exact cached artifact
(matching SHA-256), Shiboken 6.10.1 from its separate local channel,
`qt6-main` 6.10.1, and Python 3.14.7 from conda-forge. The same smoke script
passed there. This is local Linux evidence, not channel or cross-platform
admission.

## Python 3.11 regression experiment

On 23 September 2026, a disposable copy of this candidate changed only the
recipe's Python host/run pins from 3.14 to 3.11 and built against the local
Shiboken 6.10.1 `py311` artifact. The Linux-64 Conda build completed all
1,043 steps and its package tests passed, including the existing smoke
script. The result was
`pyside6-essentials-uibcdf-6.10.1-py311h3fd9d12_0.conda` (SHA-256
`9fc9c04856897229dd333300e67649aaa113fac4ef60680e1c03369c800e548a`).
The package metadata declares `python >=3.11,<3.12.0a0` and
`python_abi 3.11.* *_cp311`, so this artifact does not establish support
for 3.12 or 3.13. The experiment has not changed this branch's 3.14 recipe
and has not been uploaded. Build order, local channels and scratch-space
lessons are recorded in the
[Addons family build practices](https://github.com/uibcdf/pyside6-addons-uibcdf/blob/python-3.14-qt-6.10.1/devguide/qt_family_build_practices.md).

## Remaining gates

1. The local Addons builds against matching Essentials/Shiboken/Qt artifacts
   passed for Python 3.14 and the disposable 3.11 experiment. Repeat the
   integrated MolSysViewer Qt-host gate with exact staged-channel packages.
2. Expand platform and interpreter evidence, including 3.12 and 3.13. Stage
   the coherent family before any release or promotion to the main Conda
   label.
