import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias displayName: snapshotNameLabel.text
    property alias notes: snapshotNotesLabel.text
    property int modelIndex

    width: parent.width
    height: Theme.itemSizeMedium

    Label {
        id: snapshotNameLabel
        x: Theme.horizontalPageMargin
        width: root.width - x*2
        y: root.height/2 - height/2
            - (snapshotNotesLabel.text.length == 0 ? 0 : snapshotNotesLabel.height/2)
        truncationMode: TruncationMode.Fade
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: snapshotNotesLabel
        anchors {
            left: snapshotNameLabel.left
            right: snapshotNameLabel.right
            top: snapshotNameLabel.bottom
        }
        truncationMode: TruncationMode.Fade
        color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
    }
}
