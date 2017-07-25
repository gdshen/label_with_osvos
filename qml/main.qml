import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3
import QtQuick.Controls.Material 2.2
import Qt.labs.platform 1.0

ApplicationWindow {
    id: mainwindow
    visible: true

    Material.theme: Material.System
    Material.primary: "#FFFFFF"
    Material.foreground: "#444444"
    Material.accent: Material.Blue

    width: 640
    height: 480

    signal runOSVOS(string imgs_dir, string labels_dir)
    signal savePointsAsSVG(var points, int size, string filename)
    signal openSVGFile(string filename)

    //    minimumWidth: 400
    //    minimumHeight: 300
    title: "Label with OSVOS"

    FontLoader {
        id: font
        source: "fonts/fontello.ttf"
    }

    function changePoints(svgPoints) {
        canvas.points = []

        if (svgPoints.length > 0) {
            canvas.fillTheRegion = false
            canvas.firstPoint = false

            canvas.points.push({
                                   startPoint: {
                                       X: svgPoints[0][0],
                                       Y: svgPoints[0][1]
                                   },
                                   controlPoint: {
                                       X: svgPoints[0][2],
                                       Y: svgPoints[0][3]
                                   },
                                   targetPoint: {
                                       X: svgPoints[0][4],
                                       Y: svgPoints[0][5]
                                   }
                               })
        }

        console.log('change points')
        for (var i = 1; i < svgPoints.length; i++) {
            canvas.points.push({
                                   startPoint: canvas.points[i - 1].targetPoint,
                                   controlPoint: {
                                       X: svgPoints[i][2],
                                       Y: svgPoints[i][3]
                                   },
                                   targetPoint: {
                                       X: svgPoints[i][4],
                                       Y: svgPoints[i][5]
                                   }
                               })
        }
        canvas.requestPaint()
    }

    // this filedialog from qt.labs.platform
    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFiles
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["JPEG files (*.jpg)", "PNG files (*.png)"]
        onAccepted: {
            image.source = file
            console.log("You chose: " + file)
            statusBar.text = "Image width " + image.width + " height " + image.height
                    + "; canvas width " + canvas.width + " height " + canvas.height
            listModel.clear()
            for (var i = 0; i < files.length; i++) {
                listModel.append({
                                     imageSrc: files[i]
                                 })
            }

            area.focus = true
        }
        onRejected: {
            console.log("Cancle")
        }
    }

    FileDialog {
        id: openOverlayDialog
        fileMode: FileDialog.OpenFile
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["PNG files (*.png)"]
        onAccepted: {
            imageOverlay.source = file
            area.focus = true
        }
    }

    FileDialog {
        id: openSVGDialog
        fileMode: FileDialog.OpenFile
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["SVG files (*.svg)"]
        onAccepted: {
            console.log('load svg')
            openSVGFile(file)
            area.focus = true
        }
    }

    FileDialog {
        id: saveDialog
        fileMode: FileDialog.SaveFile
        defaultSuffix: "png"
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            console.log("Save file as " + file.toString().slice(
                            7)) // convert url to pure filename
            var result = canvas.save(file.toString().slice(7))
            console.log("Save " + result)
        }
        onRejected: {
            console.log("Rejected file save")
        }
    }

    function setStatusBarContent(content) {
        statusBar.text = content
    }

    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
    }

    MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open")
                onTriggered: console.log("File open") // todo
            }
            MenuItem {
                text: qsTr("&Save as...")
                onTriggered: console.log("File save") //todo
            }
            MenuItem {
                text: qsTr("&Quit")
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: qsTr("&Action")
            MenuItem {
                text: qsTr("Undo")
                onTriggered: console.log("undo") // todo
            }
            MenuItem {
                text: qsTr("Clear")
                onTriggered: console.log("clear") // todo
            }
        }
        Menu {
            title: qsTr("OSVOS")
            MenuItem {
                text: "Run OSVOS"
                onTriggered: console.log("run osvos") // todo
            }
        }
    }

    header: ToolBar {
        leftPadding: 8

        Flow {
            id: flow
            width: parent.width

            Row {
                id: fileRow
                ToolButton {
                    id: openButton
                    text: "\uF115"
                    font.family: "fontello"
                    onClicked: openDialog.open()
                }
                ToolButton {
                    id: openOverlayButton
                    text: "\uF115"
                    font.family: "fontello"
                    onClicked: openOverlayDialog.open()
                }
                ToolButton {
                    id: svgOpenButton
                    text: "\uF1C9"
                    font.family: "fontello"
                    onClicked: {
                        openSVGDialog.open()
                    }
                }

                ToolButton {
                    id: saveButton
                    text: "\uE800"
                    font.family: "fontello"
                    onClicked: saveDialog.open()
                }

                ToolButton {
                    id: saveSVGButton
                    text: "\uE804"
                    font.family: "fontello"
                    onClicked: {
                        buttonsModel.append({
                                                imageNumber: image.source.toString(
                                                                 ).slice(-9, -4)
                                            })
                        mainwindow.savePointsAsSVG(canvas.points,
                                                   canvas.points.length,
                                                   image.source)
                        messageDialog.text = "Save as svg file"
                        messageDialog.open()
                    }
                }

                ToolSeparator {
                    contentItem.visible: fileRow.y === actionRow.y
                }
            }

            Row {
                id: actionRow
                ToolButton {
                    id: undoButton
                    text: "\uE801"
                    font.family: "fontello"
                    onClicked: {
                        canvas.points.pop()
                        canvas.requestPaint()
                    }
                }
                ToolButton {
                    id: fillButton
                    text: "\uE802"
                    font.family: "fontello"
                    onClicked: {
                        canvas.fillTheRegion = true
                        canvas.requestPaint()
                    }
                }
                ToolButton {
                    id: clearButton
                    text: "\uF12D"
                    font.family: "fontello"
                    onClicked: {
                        canvas.points = []
                        canvas.fillTheRegion = false
                        canvas.firstPoint = true
                        console.log("clear")
                        canvas.requestPaint()
                    }
                }

                ToolSeparator {
                    contentItem.visible: actionRow.y === osvosRow.y
                }
            }

            Row {
                id: osvosRow
                ToolButton {
                    id: runOSVOSButton
                    text: "\uE803"
                    font.family: "fontello"
                    onClicked: {
                        console.log("run osvos")
                        messageDialog.text = "start to run osvos model"
                        messageDialog.open()
                        mainwindow.runOSVOS(
                                    "file:///home/gdshen/PycharmProjects/label_with_osvos/data/imgs",
                                    "file:///home/gdshen/PycharmProjects/label_with_osvos/data/annotations")
                    }
                }

                ToolSeparator {
                    contentItem.visible: osvosRow.y === testRow.y
                }
            }

            Row {
                id: testRow
                ToolButton {
                    id: testNewFunction
                    text: "\uF25A"
                    font.family: "fontello"
                    onClicked: {
                        console.log("click testnewrunction button")
                        messageDialog.text = "click test button"
                        messageDialog.open()
                    }
                }
            }
        }
    }

    footer: ToolBar {
        height: 20

        Label {
            id: statusBar
            width: parent.width
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: infoRect.left
        anchors.top: parent.top
        anchors.bottom: imageGallery.top

        anchors.margins: 5
        //        color: "#000"
        border.width: 2
        clip: true

        Image {
            id: image
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 40
            //        anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            transform: [
                Scale {
                    id: imageScale
                    xScale: 1
                    yScale: 1
                },
                Translate {
                    id: imageTranslate
                    x: 0
                    y: 0
                }
            ]
        }
        Image {
            id: imageOverlay
            opacity: 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 40
            //        anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            transform: [
                Scale {
                    id: imageOverlayScale
                    xScale: 1
                    yScale: 1
                },
                Translate {
                    id: imageOverlayTranslate
                    x: 0
                    y: 0
                }
            ]
        }

        Canvas {
            id: canvas
            width: image.width
            height: image.height
            transform: [
                Scale {
                    id: canvasScale
                    xScale: 1
                    yScale: 1
                },
                Translate {
                    id: canvasTranslate
                    x: 0
                    y: 0
                }
            ]
            anchors.top: parent.top
            anchors.horizontalCenter: image.horizontalCenter
            anchors.margins: 40

            property real lastX
            property real lastY
            //        anchors.verticalCenter: parent.verticalCenter
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
            property color bezierLineColor: "#FFF"
            property color controlLineColor: "#0FF"
            property color rectColor: "#F00"
            property real rectWidth: 5
            property bool controlPressed: false
            property bool altPressed: false
            property bool shiftPressed: false
            property int distanceThrehold: 10000
            property bool pointModifyMode: false
            property var pointToMove: null
            property bool drawAdditionalInformation: true
            property bool fillTheRegion: false

            onPaint: {
                var ctx = canvas.getContext("2d")
                ctx.clearRect(0, 0, canvas.width, canvas.height)
                if (fillTheRegion) {
                    ctx.fillStyle = '#fff'
                    ctx.beginPath()
                    ctx.moveTo(points[0].startPoint.X, points[0].startPoint.Y)
                    for (var i = 0; i < points.length; i++) {
                        ctx.quadraticCurveTo(points[i].controlPoint.X,
                                             points[i].controlPoint.Y,
                                             points[i].targetPoint.X,
                                             points[i].targetPoint.Y)
                    }
                    ctx.fill()
                    return
                }

                ctx.lineWidth = 1.5
                //            console.log("Painting" + points.length)
                for (var i = 0; i < points.length; i++) {
                    var point = points[i]

                    // draw bezier curve
                    ctx.beginPath()
                    ctx.strokeStyle = canvas.bezierLineColor
                    ctx.moveTo(point.startPoint.X, point.startPoint.Y)
                    ctx.quadraticCurveTo(point.controlPoint.X,
                                         point.controlPoint.Y,
                                         point.targetPoint.X,
                                         point.targetPoint.Y)
                    ctx.stroke()

                    if (drawAdditionalInformation) {
                        // draw the control line
                        ctx.beginPath()
                        ctx.strokeStyle = canvas.controlLineColor
                        ctx.moveTo(point.targetPoint.X, point.targetPoint.Y)
                        ctx.lineTo(point.controlPoint.X, point.controlPoint.Y)
                        ctx.stroke()

                        // draw the rect for the target point
                        ctx.beginPath()
                        ctx.strokeStyle = canvas.rectColor
                        ctx.rect(point.targetPoint.X, point.targetPoint.Y,
                                 rectWidth, rectWidth)
                        ctx.stroke()

                        // draw the rect for the control point
                        ctx.beginPath()
                        ctx.strokeStyle = canvas.rectColor
                        ctx.rect(point.controlPoint.X, point.controlPoint.Y,
                                 rectWidth, rectWidth)
                        ctx.stroke()
                    }
                }
            }

            function printPoints() {
                var message = ''
                for (var i = 0; i < points.length; i++) {
                    var startPoint = points[i].startPoint
                    var controlPoint = points[i].controlPoint
                    var targetPoint = points[i].targetPoint
                    message = message.concat('((', startPoint.X, ',',
                                             startPoint.Y, '),(',
                                             controlPoint.X, ',',
                                             controlPoint.Y, '),(',
                                             targetPoint.X, ',',
                                             targetPoint.Y, ')) ----')
                }
                console.log(message)
            }

            function computeDistance(point1, point2) {
                var deltaX = point1.X - point2.X
                var deltaY = point1.X - point2.X
                var distance = deltaX * deltaX + deltaY
                        * deltaY // return square distance, to keep distance as an integer
                return distance
            }

            function findClosedPoint(pointToCompare) {
                var shortestDistance = Infinity
                var closestPoint = null
                var distance = 0
                for (var i = 0; i < points.length; i++) {
                    var pointsOfOneBezierLine = [points[i].startPoint, points[i].targetPoint, points[i].controlPoint]
                    for (var j = 0; j < 3; j++) {
                        distance = computeDistance(pointToCompare,
                                                   pointsOfOneBezierLine[j])
                        if (distance <= shortestDistance) {
                            shortestDistance = distance
                            closestPoint = pointsOfOneBezierLine[j]
                        }
                    }
                }
                return closestPoint
            }

            MouseArea {
                id: area
                anchors.fill: parent
                focus: true // to enable the keyevent, the focus property must be set to true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onPressed: {
                    canvas.lastX = mouseX
                    canvas.lastY = mouseY
                    if (canvas.shiftPressed) {
                        return
                    }

                    console.log("Information of position after translation "
                                + mouseX + " " + mouseY)
                    if (pressedButtons === Qt.RightButton) {
                        console.log("Pressed right button")
                        canvas.drawAdditionalInformation = !canvas.drawAdditionalInformation
                        canvas.requestPaint()
                        return
                    }

                    console.log("MouseX: " + mouseX + " MouseY: " + mouseY)
                    console.log("onPressed altPressed" + canvas.altPressed)
                    if (canvas.altPressed) {
                        console.log("enter alt pressed mode")
                        var currentPoint = {
                            X: mouseX,
                            Y: mouseY
                        }
                        var point = canvas.findClosedPoint(currentPoint)
                        var distance = canvas.computeDistance(currentPoint,
                                                              point)
                        console.log("Distance is " + distance)
                        if (distance < canvas.distanceThrehold) {
                            canvas.pointModifyMode = true
                            canvas.pointToMove = point
                        }
                    } else if (canvas.firstPoint) {
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
                        if (canvas.controlPressed) {
                            console.log("enter control pressed mode")
                            var currentPoint = {
                                X: mouseX,
                                Y: mouseY
                            }
                            var point = canvas.findClosedPoint(currentPoint)
                            var distance = canvas.computeDistance(currentPoint,
                                                                  point)
                            console.log("Distance is " + distance)
                            if (distance < canvas.distanceThrehold) {
                                canvas.points.push({
                                                       startPoint: canvas.points[canvas.points.length - 1].targetPoint,
                                                       controlPoint: {
                                                           X: mouseX,
                                                           Y: mouseY
                                                       },
                                                       targetPoint: point
                                                   })
                            }
                        } else {
                            canvas.points.push({
                                                   startPoint: canvas.points[canvas.points.length
                                                       - 1].targetPoint,
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
                }

                onReleased: {
                    if (canvas.shiftPressed) {
                        return
                    }

                    if (canvas.pointModifyMode) {
                        canvas.pointModifyMode = false
                    } else {

                        console.log(canvas.points.length)
                        canvas.points[canvas.points.length - 1].controlPoint.X = mouseX
                        canvas.points[canvas.points.length - 1].controlPoint.Y = mouseY
                        if (canvas.firstPoint) {
                            canvas.firstPoint = false
                        }
                    }
                    canvas.requestPaint()
                }

                onPositionChanged: {
                    console.log("point modify mode " + canvas.pointModifyMode)

                    // process image translation
                    if (canvas.shiftPressed) {
                        var deltaX = mouseX - canvas.lastX
                        var deltaY = mouseY - canvas.lastY
                        imageTranslate.x += deltaX
                        imageTranslate.y += deltaY

                        imageOverlayTranslate.x += deltaX
                        imageOverlayTranslate.y += deltaY

                        canvasTranslate.x += deltaX
                        canvasTranslate.y += deltaY
                        //                        canvas.lastX = mouseX
                        //                        canvas.lastY = mouseY
                        return
                    }

                    // process point modify or controlpoint movement
                    if (canvas.pointModifyMode) {
                        var currentPoint = {
                            X: mouseX,
                            Y: mouseY
                        }
                        // diffferent from canvas.pointToMove = currentPoint // pass by value vs. pass by reference
                        canvas.pointToMove.X = currentPoint.X
                        canvas.pointToMove.Y = currentPoint.Y

                        canvas.printPoints()
                    } else {
                        canvas.points[canvas.points.length - 1].controlPoint.X = mouseX
                        canvas.points[canvas.points.length - 1].controlPoint.Y = mouseY
                    }
                    canvas.requestPaint()
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Control) {
                        console.log("Pressed Control")
                        canvas.controlPressed = true
                    }
                    if (event.key === Qt.Key_Alt) {
                        console.log("Pressed alt")
                        canvas.altPressed = true
                        console.log("ALtPressed " + canvas.altPressed)
                    }
                    if (event.key === Qt.Key_Shift) {
                        canvas.shiftPressed = true
                        console.log("Pressed Shift")
                    }

                    event.accepted = true
                }

                Keys.onReleased: {
                    if (event.key === Qt.Key_Control) {
                        console.log("Release control")
                        canvas.controlPressed = false
                    }
                    if (event.key === Qt.Key_Alt) {
                        console.log("Release alt")
                        canvas.altPressed = false
                    }
                    if (event.key === Qt.Key_Shift) {
                        canvas.shiftPressed = false
                        console.log("Release Shift")
                    }

                    event.accpeted = true
                }

                onWheel: {
                    if (canvas.controlPressed) {
                        console.log("current x is " + wheel.x + " " + wheel.y)
                        console.log("whell angleDelta.y is " + wheel.angleDelta.y)
                        imageScale.xScale += wheel.angleDelta.y / 1200
                        imageScale.yScale += wheel.angleDelta.y / 1200
                        imageScale.origin.x = wheel.x
                        imageScale.origin.y = wheel.y

                        imageOverlayScale.xScale += wheel.angleDelta.y / 1200
                        imageOverlayScale.yScale += wheel.angleDelta.y / 1200
                        imageOverlayScale.origin.x = wheel.x
                        imageOverlayScale.origin.y = wheel.y

                        canvasScale.xScale += wheel.angleDelta.y / 1200
                        canvasScale.yScale += wheel.angleDelta.y / 1200
                        canvasScale.origin.x = wheel.x
                        canvasScale.origin.y = wheel.y
                    }
                }
            }
        }
    }
    ListModel {
        id: listModel
    }

    ListView {
        id: imageGallery
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: infoRect.left
        height: 100
        spacing: 4
        clip: true

        model: listModel
        orientation: ListView.Horizontal
        delegate: singleImage

        Component {
            id: singleImage
            Image {
                height: ListView.height
                width: 200

                source: imageSrc
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        image.source = imageSrc
                    }
                }
            }
        }
    }

    Rectangle {
        id: infoRect
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 100
        //        height: parent.height
        border.color: "#000"
        anchors.margins: 5

        ListModel {
            id: buttonsModel
        }

        ListView {
            id: buttonsListView
            anchors.fill: parent
            clip: true
            model: buttonsModel
            delegate: singleButton

            Component {
                id: singleButton

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: imageNumber
                }
            }
        }
    }
}
