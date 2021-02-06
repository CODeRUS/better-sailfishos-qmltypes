/****************************************************************************************
**
** Copyright (c) 2019-2020 Open Mobile Platform LLC
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
    contentHeight: Math.max(image.y + image.height, content.y + content.height) + Theme.paddingLarge

    onTriggered: {
        if (eventUrl.length > 0) {
            Qt.openUrlExternally(eventUrl)
        }
    }

    Image {
        id: image
        y: Theme.paddingLarge
        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
    }

    Column {
        id: content

        anchors {
            left: image.right
            leftMargin: Theme.paddingMedium
            top: image.top
            topMargin: -Theme.paddingSmall
        }

        width: root.width - x - root.contentLeftMargin - Theme.paddingMedium
        spacing: Theme.paddingSmall

        Label {
            id: subjectLabel
            width: parent.width
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            font.bold: true
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
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }
    }
}
