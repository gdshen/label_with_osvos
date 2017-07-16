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
        id: undoAction
        text: "Undo"
        shortcut: StandardKey.Undo
        onTriggered: {
            canvas.points.pop()
            canvas.buttonPressed = 0
            canvas.requestPaint()
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
                action: closeRegionAction
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
                action: undoAction
            }
        }
    }

    Image {
        id: image
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        property real lastX: 0
        property real lastY: 0
        property real startPointX: 0
        property real startPointY: 0
        property real controlPointX: 0
        property real controlPointY: 0
        property real targetPointX: 0
        property real targetPointY: 0

        property int buttonPressed: 0

        property var points: []
        property color color: "#33B5E3"

        onPaint: {
            var ctx = canvas.getContext("2d")

            ctx.lineWidth = 1.5
            ctx.strokeStyle = canvas.color
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            if (canvas.buttonPressed === 1) {
                ctx.beginPath()
                ctx.moveTo(startPointX, startPointY)
                ctx.lineTo(lastX, lastY)
                ctx.stroke()
            } else if (canvas.buttonPressed === 2) {
                ctx.beginPath()
                ctx.moveTo(startPointX, startPointY)
                ctx.quadraticCurveTo(lastX, lastY, targetPointX, targetPointY)
                ctx.stroke()
            }

            for (var i = 0; i < points.length; i++) {
                var point = points[i]
                ctx.beginPath()
                ctx.moveTo(point.startPointX, point.startPointY)
                ctx.quadraticCurveTo(point.controlPointX, point.controlPointY,
                                     point.targetPointX, point.targetPointY)
                ctx.stroke()
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            onReleased: {
                if (canvas.buttonPressed === 0) {
                    canvas.startPointX = mouseX
                    canvas.startPointY = mouseY
                }
                if (canvas.buttonPressed === 1) {
                    canvas.targetPointX = mouseX
                    canvas.targetPointY = mouseY
                }
                if (canvas.buttonPressed === 2) {
                    canvas.controlPointX = mouseX
                    canvas.controlPointY = mouseY

                    canvas.points.push({
                                           startPointX: canvas.startPointX,
                                           startPointY: canvas.startPointY,
                                           controlPointX: canvas.controlPointX,
                                           controlPointY: canvas.controlPointY,
                                           targetPointX: canvas.targetPointX,
                                           targetPointY: canvas.targetPointY
                                       })
                    canvas.requestPaint()

                    //                    canvas.startPointX = canvas.targetPointX
                    //                    canvas.startPointY = canvas.targetPointY
                    //                    canvas.buttonPressed += 1
                }
                canvas.buttonPressed = (canvas.buttonPressed + 1) % 3
            }

            onPositionChanged: {
                canvas.lastX = mouseX
                canvas.lastY = mouseY
                if (canvas.buttonPressed === 0 && canvas.points.length > 0) {
                    // make the successive bezier curve's startPoint be the previous beizer curve's targetPoint
                    canvas.startPointX = canvas.points[canvas.points.length - 1].targetPointX
                    canvas.startPointY = canvas.points[canvas.points.length - 1].targetPointY
                    canvas.buttonPressed += 1
                }

                if (canvas.buttonPressed === 1 || canvas.buttonPressed === 2) {
                    canvas.requestPaint()
                }
            }
        }
    }
}
