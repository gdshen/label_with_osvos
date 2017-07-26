# fix opengl load error on linux platform
# according to https://bugs.launchpad.net/ubuntu/+source/python-qt4/+bug/941826
import os
from PyQt5.QtCore import QUrl
from PyQt5.QtWidgets import QApplication
from PyQt5.QtQml import QQmlApplicationEngine
from svgpathtools import QuadraticBezier, Path, wsvg, svg2paths
import argparse
import configparser

import sys
if sys.platform.startswith('linux'):
    import ctypes
    from ctypes import util
    ctypes.CDLL(util.find_library('GL'), ctypes.RTLD_GLOBAL)

os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Universal'

if __name__ == '__main__':
    # parse command line argument
    parser = argparse.ArgumentParser(description='Label with osvos')
    parser.add_argument('config', type=str, help='location of the configuration file')
    parser.add_argument('dir', type=str, help='concrete directory')
    args = parser.parse_args()
    # print(args.config)

    # parse configuration file
    config = configparser.ConfigParser()
    config.read(args.config)
    # print(config.sections())
    project_path = config['ProInfo']['ProPath']
    sequence_dir = config['ProInfo']['SequenceDir'] + '/' + args.dir
    svg_dir = config['ProInfo']['SvgDir'] + '/' + args.dir
    annotation_dir = config['ProInfo']['AnotationsDir'] + '/' + args.dir
    mask_dir = config['ProInfo']['MaskDir'] + '/' + args.dir
    # print(project_path)
    # print(sequence_dir
    # print(svg_dir)
    # print(mask_dir)

    file_lists = [file[:5] for file in sorted(os.listdir(os.path.join(project_path, sequence_dir)))]
    # print(file_lists)

    mask_key = config['Mask' + '_' + args.dir]['key'].split(',') if config['Mask']['key'] else []
    mask_svg = config['Mask' + '_' + args.dir]['svg'].split(',') if config['Mask']['svg'] else []
    mask_png = config['Mask' + '_' + args.dir]['png'].split(',') if config['Mask']['png'] else []
    key_frames = [frame[:5] for frame in mask_key]
    # print(key_frames)
    # print(mask_key)
    # print(mask_svg)
    # print(mask_png)

    # start qt/qml application
    myApp = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load(QUrl('qml/main.qml'))
    main_window = engine.rootObjects()[0]


    def osvos():
        full_sequence_dir = os.path.join(project_path, sequence_dir)
        full_annotation_dir = os.path.join(project_path, annotation_dir)
        result_dir = os.path.join(project_path, mask_dir)
        from osvos_demo import run_osvos
        run_osvos(full_sequence_dir, full_annotation_dir, result_dir, max_training_iters=10)
        # main_window.setStatusBarContent("Running osvos in the background, please check the directory yourself")


    def save_points_as_svg_handler(points, size, image_number):
        # filename like file:///home/gdshen/Pictures/00000.jpg
        filename = os.path.join(project_path, svg_dir, image_number+'.svg')
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


    def open_svg_file_load_points_handler(image_number):
        filename = os.path.join(project_path, svg_dir, image_number+'.svg')

        # parse svg file
        points = []
        paths, attributes = svg2paths(filename)
        for path in paths:
            bezier_curve = path[0]
            points.append(
                [bezier_curve.start.real, bezier_curve.start.imag, bezier_curve.control.real, bezier_curve.control.imag,
                 bezier_curve.end.real, bezier_curve.end.imag])
        main_window.changePoints(points)


    def write_ini(image_numbers, size):
        image_numbers = [image_numbers.property(i).toString() for i in range(size)]
        jpg_lists = [number+'.jpg' for number in image_numbers]
        svg_lists = [number+'.svg' for number in image_numbers]
        png_lists = [number+'.png' for number in image_numbers]
        config['Mask' + '_' + args.dir]['key'] = ','.join(jpg_lists)
        config['Mask' + '_' + args.dir]['svg'] = ','.join(svg_lists)
        config['Mask' + '_' + args.dir]['png'] = ','.join(png_lists)
        with open(args.config, 'w') as configfile:
            config.write(configfile)


    main_window.runOSVOS.connect(osvos)
    main_window.savePointsAsSVG.connect(save_points_as_svg_handler)
    main_window.openSVGFile.connect(open_svg_file_load_points_handler)
    main_window.writeIni.connect(write_ini)
    main_window.setProperty('fileLists', file_lists)
    main_window.setProperty('keyFrames', key_frames)
    main_window.setProperty('sequenceDir', os.path.join(project_path, sequence_dir))
    main_window.setProperty('svgDir', os.path.join(project_path, svg_dir))
    main_window.setProperty('annotationDir', os.path.join(project_path, annotation_dir))
    main_window.setProperty('maskDir', os.path.join(project_path, mask_dir))
    main_window.initializeListView()

    sys.exit(myApp.exec_())
