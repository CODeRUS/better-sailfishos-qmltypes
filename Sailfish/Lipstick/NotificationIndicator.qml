/****************************************************************************
 **
 ** Copyright (C) 2015-2020 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

SilicaItem {
    id: root

    property int count
    property alias iconSource: icon.iconSource
    property alias iconColor: icon.iconColor
    property bool showCount: count > 1

    height: icon.height
    width: Math.max(countLabel.width + countLabel.anchors.leftMargin + icon.width + Theme.paddingSmall,
                    icon.width + 2*Theme.paddingLarge)

    NotificationAppIcon {
        id: icon
    }

    Label {
        id: countLabel

        anchors {
            left: icon.right
            leftMargin: Theme.paddingSmall
            verticalCenter: icon.verticalCenter
        }
        text: root.count > 99 ? '99+' : root.count
        font.pixelSize: Theme.fontSizeSmall
        visible: opacity > 0
        opacity: root.showCount ? 1 : 0

        Behavior on opacity { FadeAnimator {} }
    }
}
