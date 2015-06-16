import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias text: label.text
    property alias active: label.active

    default property alias data: container.data

    signal editorItemClicked

    width: parent.width
    height: active ? label.height + container.height + Theme.paddingMedium : label.height
    clip: true

    Behavior on height { NumberAnimation {
            target: root
            properties: "height"
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    EditorTitleButton {
        id: label
        onClicked: editorItemClicked()
    }

    // Use column here because it handles layouting children nicely
    Column {
        id: container
        width: parent.width
        anchors {
            top: label.bottom
            topMargin: Theme.paddingMedium
        }

        opacity: root.active ? 1 : 0
        Behavior on opacity { FadeAnimation {} }
    }
}
