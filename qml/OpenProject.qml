import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {

    anchors.margins: 20
    anchors.fill: parent

    Button {
        id: newProjectButton
        anchors.bottom: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "New Project"
        onClicked: {
            toolBarInMainWindow.visible = true
            stack.push(mainView)
        }
    }

    Button {
        id: openProjectButton
        anchors.top: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Open Project"
        onClicked: {
            toolBarInMainWindow.visible = true
            stack.push(mainView)
        }
    }
}
