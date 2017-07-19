import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.1

ApplicationWindow {
    id: mainwindow
    visible: true
    width: 640
    height: 480

    signal runOSVOS(string message)

    //    minimumWidth: 400
    //    minimumHeight: 300
    title: "Label with OSVOS"

    FileDialog {
        id: fileDialog
        title: "Open a directory"
        selectExisting: true
        folder: shortcuts.home
        onAccepted: {
            image.source = fileDialog.fileUrl
            console.log("You chose: " + fileDialog.fileUrl)
        }
        onRejected: {
            console.log("Cancle")
        }
    }

    FileDialog {
        id: fileSaveDialog
        title: "Save file as"
        selectExisting: false
        onAccepted: {
            console.log("Save file as " + fileSaveDialog.fileUrl.toString(
                            ).slice(8)) // convert url to pure filename
            var result = canvas.save(fileSaveDialog.fileUrl.toString().slice(8))
            console.log("Save " + result)
        }
        onRejected: {
            console.log("Rejected file save")
        }
    }

    Action {
        id: fileOpenAction
        text: "Open"
        shortcut: StandardKey.Open
        onTriggered: {
            //            fileDialog.selectFolder = true
            fileDialog.open()
        }
    }

    Action {
        id: saveCurrentCanvas
        text: "Save"
        shortcut: StandardKey.Save
        onTriggered: {
            fileSaveDialog.open()
        }
    }

    Action {
        id: fillAction
        text: "Fill"
        onTriggered: {
            canvas.fillTheRegion = true
            canvas.requestPaint()
        }
    }

    Action {
        id: closeRegionAction
        text: "Close"
        onTriggered: {
            if (canvas.points.length > 0) {
                canvas.startPointX = canvas.points[canvas.points.length - 1].targetPointX
                canvas.startPointY = canvas.points[canvas.points.length - 1].targetPointY
                canvas.targetPointX = canvas.points[0].startPointX
                canvas.targetPointY = canvas.points[0].startPointY
                canvas.buttonPressed = 2
            }
        }
    }

    Action {
        id: clearAction
        text: "Clear"
        onTriggered: {
            canvas.buttonPressed = 0
            canvas.points = []
            canvas.fillTheRegion = false
            console.log("Clear")
            canvas.requestPaint()
        }
    }

    Action {
        id: undoAction
        text: "Undo"
        shortcut: StandardKey.Undo
        onTriggered: {
            canvas.points.pop()
            canvas.buttonPressed = 0
            canvas.requestPaint()
        }
    }

    Action {
        id: runOSVOSAction
        text: "run"
        onTriggered: {
            console.log("run osvos")
            mainwindow.runOSVOS("a long message")
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "&File"
            MenuItem {
                action: fileOpenAction
            }
            MenuItem {
                action: saveCurrentCanvas
            }
            MenuItem {
                text: "Quit"
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: "&Action"
            MenuItem {
                action: undoAction
            }
            MenuItem {
                action: clearAction
            }
            MenuItem {
                action: closeRegionAction
            }
        }
        Menu {
            title: "OSVOS"
            MenuItem {
                action: runOSVOSAction
            }
        }
    }

    toolBar: ToolBar {
        id: mainToolBar
        width: parent.width
        RowLayout {
            anchors.fill: parent
            spacing: 0
            ToolButton {
                action: fileOpenAction
            }
            ToolButton {
                action: saveCurrentCanvas
            }
            ToolButton {
                action: closeRegionAction
            }
            ToolButton {
                action: fillAction
            }
            ToolButton {
                action: undoAction
            }
            ToolButton {
                action: clearAction
            }
            ToolButton {
                action: runOSVOSAction
            }
        }
    }

    statusBar: StatusBar {
        RowLayout {
            anchors.fill: parent
            Label {
                id: statusBarLabel
                text: "Status Bar"
            }
        }
    }

    function setStatusBarContent(content) {
        statusBarLabel.text = content
    }

    Image {
        id: image
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property real lastX: 0
        property real lastY: 0
        property var startPoint: {
            X: 0
            Y: 0
        }
        property var controlPoint: {
            X: 0
            Y: 0
        }
        property real targetPoint: {
            X: 0
            Y: 0
        }

        property bool firstPoint: true

        property var points: []
        property color bezierLineColor: "#000"
        property color controlLineColor: "#0FF"
        property color rectColor: "#F00"
        property real rectWidth: 5

        onPaint: {
            var ctx = canvas.getContext("2d")
            ctx.clearRect(0, 0, canvas.width, canvas.height)

            ctx.lineWidth = 1.5
            console.log("Painting" + points.length)
            for (var i = 0; i < points.length; i++) {
                var point = points[i]

                // draw bezier curve
                ctx.beginPath()
                ctx.strokeStyle = canvas.bezierLineColor
                ctx.moveTo(point.startPoint.X, point.startPoint.Y)
                ctx.quadraticCurveTo(point.controlPoint.X,
                                     point.controlPoint.Y, point.targetPoint.X,
                                     point.targetPoint.Y)
                ctx.stroke()

                // draw the control line
                ctx.beginPath()
                ctx.strokeStyle = canvas.controlLineColor
                ctx.moveTo(point.targetPoint.X, point.targetPoint.Y)
                ctx.lineTo(point.controlPoint.X, point.controlPoint.Y)
                ctx.stroke()

                // draw the rect for the target point
                ctx.beginPath()
                ctx.strokeStyle = canvas.rectColor
                ctx.rect(point.targetPoint.X, point.targetPoint.Y, rectWidth,
                         rectWidth)
                ctx.stroke()

                // draw the rect for the control point
                ctx.beginPath()
                ctx.strokeStyle = canvas.rectColor
                ctx.rect(point.controlPoint.X, point.controlPoint.Y, rectWidth,
                         rectWidth)
                ctx.stroke()
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent

            onPressed: {
                if (canvas.firstPoint) {
                    canvas.points.push({
                                           startPoint: {
                                               X: mouseX,
                                               Y: mouseY
                                           },
                                           controlPoint: {
                                               X: mouseX,
                                               Y: mouseY
                                           },
                                           targetPoint: {
                                               X: mouseX,
                                               Y: mouseY
                                           }
                                       })
                } else {
                    var spx = canvas.points[canvas.points.length - 1].targetPoint.X
                    var spy = canvas.points[canvas.points.length - 1].targetPoint.Y
                    canvas.points.push({
                                           startPoint: {
                                               X: spx,
                                               Y: spy
                                           },
                                           controlPoint: {
                                               X: mouseX,
                                               Y: mouseY
                                           },
                                           targetPoint: {
                                               X: mouseX,
                                               Y: mouseY
                                           }
                                       })
                }
            }

            onReleased: {
                console.log(canvas.points.length)
                canvas.points[canvas.points.length - 1].controlPoint.X = mouseX
                canvas.points[canvas.points.length - 1].controlPoint.Y = mouseY
                if (canvas.firstPoint) {
                    canvas.firstPoint = false
                }

                canvas.requestPaint()
            }

            onPositionChanged: {
                canvas.points[canvas.points.length - 1].controlPoint.X = mouseX
                canvas.points[canvas.points.length - 1].controlPoint.Y = mouseY
                canvas.requestPaint()
            }
        }
    }
}
