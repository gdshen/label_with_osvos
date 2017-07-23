# fix opengl load error on linux platform
# according to https://bugs.launchpad.net/ubuntu/+source/python-qt4/+bug/941826
import os

os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Material'

import ctypes
from ctypes import util

ctypes.CDLL(util.find_library('GL'), ctypes.RTLD_GLOBAL)

import sys
from PyQt5.QtCore import QUrl, QObject, pyqtSignal, pyqtSlot
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5.QtQml import QQmlEngine, QQmlComponent, QQmlApplicationEngine
from PyQt5.QtQuick import QQuickView

from svgpathtools import QuadraticBezier, Path, wsvg, svg2paths

if __name__ == '__main__':
    myApp = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load(QUrl('qml/main.qml'))
    main_window = engine.rootObjects()[0]


    def osvos(message):
        from osvos_demo import run_osvos
        main_window.setStatusBarContent("Training")
        # run_osvos()
        print("run osvos")
        main_window.setStatusBarContent("Finished")


    def save_points_as_svg_handler(points, size, filename):
        # filename like file:///home/gdshen/Pictures/00000.jpg
        filename = filename.split('/')[-1].split('.')[0] + '.svg'
        paths = []
        for i in range(size):
            start_point_x = points.property(i).property('startPoint').property('X').toInt()
            start_point_y = points.property(i).property('startPoint').property('Y').toInt()
            control_point_x = points.property(i).property('controlPoint').property('X').toInt()
            control_point_y = points.property(i).property('controlPoint').property('Y').toInt()
            target_point_x = points.property(i).property('targetPoint').property('X').toInt()
            target_point_y = points.property(i).property('targetPoint').property('Y').toInt()
            print(start_point_x, start_point_y, control_point_x, control_point_y, target_point_x, target_point_y)
            paths.append(
                Path(QuadraticBezier(complex(start_point_x, start_point_y), complex(control_point_x, control_point_y),
                                     complex(target_point_x, target_point_y))))

        wsvg(paths=paths, filename=filename)


    def open_svg_file_load_points_handler(filename):
        print(filename)
        filename = filename[7:]

        # parse svg file
        points = []
        paths, attributes = svg2paths(filename)
        for path in paths:
            bezier_curve = path[0]
            points.append(
                [bezier_curve.start.real, bezier_curve.start.imag, bezier_curve.control.real, bezier_curve.control.imag,
                 bezier_curve.end.real, bezier_curve.end.imag])
        main_window.changePoints(points)


    # main_window.runOSVOS.connect(osvos)
    main_window.savePointsAsSVG.connect(save_points_as_svg_handler)
    main_window.openSVGFile.connect(open_svg_file_load_points_handler)

    sys.exit(myApp.exec_())
