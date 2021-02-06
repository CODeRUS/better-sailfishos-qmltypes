/****************************************************************************
 **
 ** Copyright (C) 2013-2020 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.Background 1.0
import org.nemomobile.lipstick 0.1

NotificationBaseItem {
    id: root

    property alias name: nameLabel.text
    property alias iconSource: icon.iconSource
    property alias iconColor: icon.iconColor
    property int textLeftMargin: contentLeftMargin + icon.width + spacer.width
    property alias icon: icon

    roundedCorners: Corners.TopLeft | Corners.TopRight
    contentHeight: row.height + 2*Theme.paddingSmall

    height: contentHeight

    Row {
        id: row
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        enabled: housekeeping && !root.userRemovable

        // Fade out item in housekeeping mode, if not removable
        opacity: enabled ? Theme.opacityLow : 1.0
        Behavior on opacity { FadeAnimator { duration: 200 }}

        NotificationAppIcon {
            id: icon

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: spacer
            height: 1
            width: Theme.paddingMedium + Theme.paddingSmall
        }

        Label {
            id: nameLabel

            font.pixelSize: Theme.fontSizeSmall
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - parent.spacing - icon.width
            textFormat: Text.PlainText
            maximumLineCount: 1
            truncationMode: TruncationMode.Fade
        }
    }
}
