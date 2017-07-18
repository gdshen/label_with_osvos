# fix opengl load error on linux platform
# according to https://bugs.launchpad.net/ubuntu/+source/python-qt4/+bug/941826
import ctypes
from ctypes import util
ctypes.CDLL(util.find_library('GL'), ctypes.RTLD_GLOBAL)

import sys
from PyQt5.QtCore import QUrl, QObject, pyqtSignal, pyqtSlot
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5.QtQml import QQmlEngine, QQmlComponent, QQmlApplicationEngine
from PyQt5.QtQuick import QQuickView
from osvos_demo import run_osvos


if __name__ == '__main__':
    myApp = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    # context = engine.rootContext()
    # context.setContextProperty()
    engine.load(QUrl('qml/main.qml'))
    main_window = engine.rootObjects()[0]

    def osvos(message):
        main_window.setStatusBarContent("Training")
        # run_osvos()
        print("run osvos")
        main_window.setStatusBarContent("Finished")

    main_window.runOSVOS.connect(osvos)

    sys.exit(myApp.exec_())
