import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "common/common.js" as CommonJs

ListItem {
    width: root.width
    height: Theme.itemSizeSmall
    opacity: enabled ? 1.0 : 0.4

    property Person person: model.person

    Image {
        id: icon
        x: Theme.paddingMedium
        anchors.verticalCenter: parent.verticalCenter
        source: person ? CommonJs.syncTargetIcon(person) + "?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
                       : ""
    }
    Label {
        id: nameLabel
        anchors {
            left: icon.right
            leftMargin: Theme.paddingSmall
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: syncTargetLabel.text !== ""
                                  ? -(syncTargetLabel.implicitHeight/2)
                                  : 0
        }
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        text: person ? person.displayLabel : ''
    }
    Label {
        id: syncTargetLabel
        anchors {
            left: icon.right
            leftMargin: Theme.paddingSmall
            top: nameLabel.bottom
        }
        text: person ? CommonJs.syncTargetDisplayName(person) : ''
        font.pixelSize: Theme.fontSizeExtraSmall
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }
}
