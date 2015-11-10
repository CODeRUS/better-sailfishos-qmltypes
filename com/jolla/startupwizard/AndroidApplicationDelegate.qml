/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Bea Lam <bea.lam@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

BackgroundItem {
    id: root

    property bool selected: model.preselected
    property bool beingInstalled

    width: parent.width
    height: icon.height + Theme.paddingMedium * 2
    enabled: !beingInstalled

    // don't show the default BackgroundItem highlight as we are providing our own in order to
    // show a custom background when the item is selected or being installed
    highlightedColor: "transparent"

    onClicked: {
        selected = !selected
    }

    Rectangle {
        anchors.fill: parent
        color: root.highlighted || root.beingInstalled
               ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
               : (root.selected ? Theme.rgba(Theme.highlightBackgroundColor, 0.1) : "transparent")
        opacity: root.beingInstalled ? 0.3 : 1
    }

    LauncherIcon {
        id: icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        opacity: root.beingInstalled ? 0.3 : 1
        source: model.icon
        pressed: root.highlighted
    }

    BusyIndicator {
        anchors.centerIn: icon
        running: root.beingInstalled || icon.status != Image.Ready
    }

    Label {
        id: nameLabel
        anchors {
            left: icon.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: icon.verticalCenter
            verticalCenterOffset: -detailLabel.height/2
        }
        font.pixelSize: Theme.fontSizeSmall
        maximumLineCount: 2
        truncationMode: TruncationMode.Elide
        wrapMode: Text.Wrap
        text: model.displayName
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        opacity: root.beingInstalled ? 0.3 : 1
    }

    Label {
        id: detailLabel
        anchors {
            left: nameLabel.left
            right: nameLabel.right
            top: nameLabel.bottom
        }
        font.pixelSize: Theme.fontSizeExtraSmall
        maximumLineCount: 2
        truncationMode: TruncationMode.Elide
        wrapMode: Text.Wrap
        text: model.summary
        opacity: root.beingInstalled ? 0.3 : 1

        // don't use secondaryHighlightColor; it's too hard to read the small text
        color: highlighted ? Theme.highlightColor : Theme.secondaryColor
    }

    Image {
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            right: parent.right
            rightMargin: Theme.paddingSmall
        }
        visible: selected
        source: "image://theme/icon-s-installed" + (highlighted ? "?" + Theme.highlightColor : "")
        opacity: root.beingInstalled ? 0.3 : 1
    }
}
