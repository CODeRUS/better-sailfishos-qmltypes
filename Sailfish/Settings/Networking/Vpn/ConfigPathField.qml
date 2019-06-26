import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property string path

    property alias fileName: textField.text
    property alias label: textField.label
    property alias placeholderText: textField.placeholderText

    width: parent.width
    height: Math.max(iconButton.height, textField.height)
    highlighted: textFieldArea.down

    function _selectFile(initialPath) {
        // initialPath is not currently handled by the file picker...
        var obj = pageStack.animatorPush("Sailfish.Pickers.FilePickerPage")
        obj.pageCompleted.connect(function(picker) {
            picker.selectedContentPropertiesChanged.connect(function() {
                path = picker.selectedContentProperties['filePath']
            })
        })
    }

    function _clearSelection() {
        path = ''
    }

    IconButton {
        id: iconButton

        x: parent.width - width
        y: -Theme.paddingMedium
        icon.source: "image://theme/icon-m-" + (root.path ? "clear" : "add") + (root.highlighted ? "?" + Theme.highlightColor : "")

        onClicked: {
            if (root.path) {
                root._clearSelection()
            } else {
                root._selectFile()
            }
        }
    }

    TextField {
        id: textField

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - iconButton.width
        placeholderText: label
        highlighted: activeFocus || root.highlighted
        text: {
            if (root.path) {
                var i = root.path.lastIndexOf('/')
                if (i != -1) {
                    return root.path.substr(i + 1)
                }
            }
            return root.path
        }
    }

    MouseArea {
        id: textFieldArea

        property bool down: pressed && containsMouse

        anchors.fill: textField
        onClicked: root._selectFile(root.path)
    }
}
