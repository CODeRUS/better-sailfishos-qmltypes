/****************************************************************************
 **
 ** Copyright (C) 2013-2019 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import org.nemomobile.lipstick 0.1

BackgroundItem {
    id: root

    //% "Show more..."
    property string defaultTitle: qsTrId("lipstick-jolla-home-bt-show_more")
    property alias title: showMore.text
    property alias showRemainingCount: remainingCountLabel.visible
    property int remainingCount
    property bool expandable: true

    onPressAndHold: if (!Lipstick.compositor.eventsLayer.housekeeping) Lipstick.compositor.eventsLayer.setHousekeeping(true)

    opacity: enabled ? 1 : 0
    implicitHeight: row.height + 2*Theme.paddingMedium
    height: Math.max(Theme.paddingSmall, (expandable ? 1 : opacity) * implicitHeight)
    Behavior on opacity { FadeAnimation {} }

    Row {
        id: row
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        Label {
            id: showMore
            text: defaultTitle
            font.pixelSize: Theme.fontSizeExtraSmall
        }
        Label {
            id: remainingCountLabel
            visible: root.remainingCount > 0
            text: "+" + root.remainingCount.toLocaleString()
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }
}
