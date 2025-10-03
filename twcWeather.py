import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QIcon
from PySide6.QtCore import QUrl

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setDesktopFileName('Weather')
    app.setWindowIcon(QIcon(os.path.join(CURRENT_DIR, "03d.png")))
    engine = QQmlApplicationEngine()
    # engine.quit.connect(app.quit)
    engine.addImportPath("/usr/lib/qt6/qml")
    engine.load(QUrl.fromLocalFile(os.path.join(CURRENT_DIR, "main.qml")))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
