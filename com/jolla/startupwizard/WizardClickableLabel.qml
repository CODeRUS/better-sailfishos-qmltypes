import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0

Label {
    id: root

    property alias pressed: mouseArea.pressed

    color: mouseArea.pressed ? wizardManager.defaultHighlightColor() : wizardManager.defaultPrimaryColor()
    width: parent.width
    wrapMode: Text.Wrap
    height: implicitHeight

    signal clicked

    StartupWizardManager {
        id: wizardManager
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
            margins: -Theme.paddingLarge
        }
        onClicked: root.clicked()
    }
}
