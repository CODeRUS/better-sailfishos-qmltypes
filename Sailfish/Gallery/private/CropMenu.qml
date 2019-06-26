import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root

    property bool active
    property string type: "original"
    property real ratio: -1

    property Item _highlightedItem
    property Item _selectedItem: repeater.itemAt(1)

    signal selected
    signal canceled

    onActiveChanged: if (active) highlightBar.highlight(_selectedItem, contentColumn)

    anchors.fill: parent
    color: Theme.colorScheme == Theme.LightOnDark ? Theme.rgba(Theme.highlightDimmerColor, 0.8)
                                                  : Theme.rgba(Theme.lightPrimaryColor, 0.8)

    MouseArea {
        anchors.fill: parent
        onClicked: root.canceled()
    }

    SilicaFlickable {
        id: flickable
        width: parent.width
        height: Math.min(parent.height, contentHeight)
        anchors.verticalCenter: parent.verticalCenter
        contentHeight: contentColumn.y + contentColumn.height + Theme.paddingLarge

        HighlightBar { id: highlightBar }

        Label {
            id: titleLabel

            //% "Aspect ratio"
            text: qsTrId("components_gallery-he-aspect_ratio")
            width: parent.width - x
            y: Theme.paddingLarge
            x: Theme.horizontalPageMargin
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            height: Theme.itemSizeSmall
        }

        Column {
            id: contentColumn

            width: parent.width
            anchors.top: titleLabel.bottom

            Repeater {
                id: repeater
                model: AspectRatioModel {}
                MenuItem {
                    text: model.text
                    onClicked: {
                        root.type = model.type
                        root.ratio = model.ratio
                        root.selected()
                    }
                }
            }
        }

        MouseArea {
            parent: flickable
            enabled: root.active
            anchors.fill: parent

            function itemAt(yPos) {
                var pos = mapToItem(contentColumn, width/2, yPos)
                var item = contentColumn.childAt(pos.x, pos.y)
                return item && item.__silica_menuitem !== undefined ? item : null
            }
            function updateHighlight(yPos) {
                if (_highlightedItem && itemAt(yPos) !== _highlightedItem) {
                    clearHighlight()
                }
            }
            function clearHighlight() {
                if (_highlightedItem) {
                    highlightBar.clearHighlight()
                    _highlightedItem.down = false
                    _highlightedItem = null
                }
            }

            onPressed: {
                _highlightedItem = itemAt(mouse.y)
                if (_highlightedItem) {
                    highlightBar.highlight(_highlightedItem, contentColumn)
                    _highlightedItem.down = true
                }
            }
            onPositionChanged: updateHighlight(mouse.y)
            onClicked: {
                updateHighlight(mouse.y)
                if (_highlightedItem) {
                    _highlightedItem.clicked()
                    _selectedItem = _highlightedItem
                } else {
                    root.canceled()
                }
                clearHighlight()
            }
            onCanceled: {
                clearHighlight()
            }
        }
        VerticalScrollDecorator {}
    }
}
