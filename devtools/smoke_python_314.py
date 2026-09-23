"""Smoke-test the Python 3.14 / Qt 6.10.1 standalone candidate."""

import os


def main():
    os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

    import shiboken6_uibcdf as shiboken
    from PySide6_uibcdf import QtCore, QtGui, QtNetwork, QtQml, QtQuick, QtWidgets

    assert shiboken.__version__ == "6.10.1"
    assert QtCore.qVersion() == "6.10.1"
    assert QtGui.QColor("steelblue").isValid()
    request = QtNetwork.QNetworkRequest(QtCore.QUrl("https://example.org"))
    assert request.url().host() == "example.org"

    class Emitter(QtCore.QObject):
        fired = QtCore.Signal(int)

    app = QtWidgets.QApplication([])
    received = []
    emitter = Emitter()
    emitter.fired.connect(received.append)
    emitter.fired.emit(7)
    assert received == [7]
    assert shiboken.isValid(emitter)

    item = QtQuick.QQuickItem()
    engine = QtQml.QQmlEngine()
    assert shiboken.isValid(item)
    assert shiboken.isValid(engine)

    QtCore.QTimer.singleShot(0, app.quit)
    assert app.exec() == 0
    print("Python 3.14 / Qt 6.10.1 clean-install smoke passed")


if __name__ == "__main__":
    main()
