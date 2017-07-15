import sys
from PyQt5.QtCore import QUrl
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlEngine, QQmlComponent, QQmlApplicationEngine
from PyQt5.QtQuick import QQuickView

if __name__ == '__main__':
    myApp = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load(QUrl('qml/main.qml'))
    # quickView = QQuickView()
    # quickView.setSource(QUrl('basic.qml'))
    # quickView.show()

    myApp.exec_()
    sys.exit()
