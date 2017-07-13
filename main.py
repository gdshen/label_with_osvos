import os
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QDesktopWidget, QMenu, QAction, QFileDialog


class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self.image_lists = []
        self.init_ui()

    def init_ui(self):
        self.create_menus()
        self.setGeometry(300, 300, 300, 300)
        self.setWindowTitle("Label with osvos")
        self.center()
        self.show()

    def create_menus(self):
        menu_bar = self.menuBar()
        file_menu = menu_bar.addMenu('&File')

        open_action = QAction('Open', file_menu)
        open_action.setShortcut('Ctrl+O')
        open_action.setStatusTip('Open Directory')
        open_action.triggered.connect(self.open_directory)

        file_menu.addAction(open_action)

    def open_directory(self):
        fname = QFileDialog.getExistingDirectory(self, 'Open directory')
        if fname:
            self.image_lists = os.listdir(fname)

    def center(self):
        qr = self.frameGeometry()
        cp = QDesktopWidget().availableGeometry().center()
        qr.moveCenter(cp)
        self.move(qr.topLeft())


if __name__ == '__main__':
    app = QApplication(sys.argv)
    win = Window()
    sys.exit(app.exec_())
