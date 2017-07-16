import sys
from PyQt5.QtCore import QUrl, QObject, pyqtSignal, pyqtSlot
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlEngine, QQmlComponent, QQmlApplicationEngine
from PyQt5.QtQuick import QQuickView


def osvos():
    print('run osvos')

if __name__ == '__main__':
    myApp = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    # context = engine.rootContext()
    # context.setContextProperty()
    engine.load(QUrl('qml/main.qml'))
    main_window = engine.rootObjects()[0]
    main_window.runOSVOS.connect(osvos)
    sys.exit(myApp.exec_())
