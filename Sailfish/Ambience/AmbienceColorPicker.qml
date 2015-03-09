import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Ambience 1.0

Grid {
    id: root

    property color color
    property alias colorCount: colorRepeater.count
    columns: 3
    width: parent.width

    property Item _tickIcon

    Component {
        id: tickIconComponent
        Image {
            property color modifierColor
            anchors {
                right: parent.right
                rightMargin: Theme.paddingMedium
                bottom: parent.bottom
                bottomMargin: Theme.paddingMedium
            }
            source: "image://theme/icon-s-installed?" + Qt.darker(modifierColor, 1.4)
        }
    }

    Repeater {
        id: colorRepeater
        model: AmbienceModel {
            id: ambienceModel
        }

        Rectangle {
            id: coloredSquare
            height: width
            width: root.width/root.columns
            color: model.highlightBackgroundColor

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    if (_tickIcon == null) {
                        _tickIcon = tickIconComponent.createObject(root)
                    }
                    _tickIcon.parent = coloredSquare
                    _tickIcon.modifierColor = model.highlightBackgroundColor
                    root.color = model.highlightBackgroundColor
                    ambienceModel.makeCurrent(model.index)
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.rgba("white", 0.4)
                    opacity: (mouseArea.pressed && mouseArea.containsMouse) ? 1.0 : 0.0
                }
            }
        }
    }
}
