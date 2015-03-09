import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: contentItem
    property string tag: name

    showMenuOnPressAndHold: false
    contentHeight: Theme.itemSizeLarge

    onPressAndHold: if (snapshotsList.enabled) showMenu({tag: tag})

    Column {
        id: description

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }

        Label {
            text: tagDateString(name)
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }
        Label {
            text: note || "..."
            font.pixelSize: Theme.fontSizeSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        }
    }

    states: [
        State {
            name: "enabled"
            when: snapshotsList.enabled
            PropertyChanges { target: contentItem; opacity: 1.0 }
        }
        , State {
            name: "disabled"
            when: !snapshotsList.enabled
            PropertyChanges { target: contentItem; opacity: 0.0 }
        }
    ]

    function tagDateString(tag) {
        if (tag.match(/[0-9-]+T[0-9.-]+Z/)) {
            var ss = function(b, e) {
                return parseInt(tag.substring(b, e), 10);
            }
            var dat = new Date(
                Date.UTC(ss(0, 4), ss(5, 7)-1, ss(8, 10),
                         ss(11, 13), ss(14, 16),
                         ss(17, 19), 0));
            return Qt.formatDateTime(dat);
        } else {
            return tag;
        }
    }

    function deleteSnapshot() {
        var tag_to_delete = tag;
        snapshotsList.clear();
        restoreItem.rmSnapshot(tag_to_delete);
    }

    function maybeDeleteSnapshot() {
        //% "Deleting backup"
        remorseAction(qsTrId("vault-me-deleting-backup"), function() {
            deleteSnapshot();
        }, 5000)
    }

}
