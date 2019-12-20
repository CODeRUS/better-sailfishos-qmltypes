/****************************************************************************
 **
 ** Copyright (C) 2013-2014 Jolla Ltd.
 ** Contact: Bea Lam <bea.lam@jollamobile.com>
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import org.nemomobile.lipstick 0.1

BackgroundItem {
    id: root

    property alias title: showMore.text
    property bool expandable: true
    property bool inRemovableGroup
    property int animationDuration: 250

    property alias defaultTitle: showMore.defaultText

    property real _expandedHeight: showMore.height + 2*Theme.paddingMedium

    property real contentLeftMargin: inRemovableGroup && Lipstick.compositor.eventsLayer.housekeeping
                                     ? (_deleteIconMargin + Theme.iconSizeMedium + _deleteIconMargin)
                                     : Theme.horizontalPageMargin

    property real _deleteIconMargin: Theme.paddingLarge

    opacity: expandable ? 1 : 0
    implicitHeight: _expandedHeight * opacity

    Behavior on opacity {
        FadeAnimation {
            duration: root.animationDuration
        }
    }

    Behavior on contentLeftMargin {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
        }
    }

    ShowMoreButton {
        id: showMore

        anchors {
            left: parent.left
            leftMargin: contentLeftMargin
            right: parent.right
            rightMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        enabled: false
        highlighted: root.highlighted
    }
}
