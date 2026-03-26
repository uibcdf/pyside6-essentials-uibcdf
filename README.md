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
