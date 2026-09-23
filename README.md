# pyside6-essentials-uibcdf

Experimental UIBCDF packaging of the PySide6 Essentials slice for the
standalone Qt-for-Python stack used by MolSysViewer. The binding imports as
`PySide6_uibcdf` and consumes the aligned `shiboken6-uibcdf` package.

The published 6.9.2 line targets Linux and Python 3.13. The
`python-3.14-qt-6.10.1` branch is an **unreleased candidate** based on
official Qt for Python 6.10.1 source. Its first target is Linux/Python 3.14
with conda-forge `qt6-main=6.10.1` and the matching Shiboken 6.10.1
candidate. A source branch or isolated package build does not establish
support for the complete Qt host or for other platforms.

The active Conda recipe builds the source in this repository. Historical
bootstrap notes and any staged wheel manifests describe the old 6.9.2
investigation; they are not the current recipe input. See the
[Python 3.14 transition checkpoint](devguide/python_3_14_transition.md)
and [issue #1](https://github.com/uibcdf/pyside6-essentials-uibcdf/issues/1)
for provenance, evidence and remaining release gates.
