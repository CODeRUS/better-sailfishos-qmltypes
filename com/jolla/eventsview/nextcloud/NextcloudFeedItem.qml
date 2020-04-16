/****************************************************************************************
**
** Copyright (c) 2019 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import com.jolla.eventsview.nextcloud 1.0

NotificationGroupMember {
    id: root

    property alias icon: image
    property alias subject: subjectLabel.text
    property alias message: messageLabel.text
    property var timestamp
    property string eventUrl

    width: parent.width
    contentWidth: width - contentLeftMargin
    contentHeight: Math.max(image.y + image.height, content.y + content.height) + Theme.paddingLarge
    deleteIconCenterY: image.y + image.height/2

    onClicked: {
        if (eventUrl.length > 0) {
            Qt.openUrlExternally(eventUrl)
        }
    }

    Image {
        id: image
        y: Theme.paddingLarge
        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
    }

    Column {
        id: content

        anchors {
            left: image.right
            leftMargin: Theme.paddingMedium
            top: image.top
            topMargin: -Theme.paddingSmall
        }

        width: root.contentWidth - x - Theme.paddingMedium
        spacing: Theme.paddingSmall

        Label {
            id: subjectLabel
            width: parent.width
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            id: messageLabel
            visible: text.length !== 0
            width: parent.width
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
            id: timestampLabel
            text: Format.formatDate(root.timestamp, Format.DurationElapsed)
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.secondaryColor
        }
    }
}
