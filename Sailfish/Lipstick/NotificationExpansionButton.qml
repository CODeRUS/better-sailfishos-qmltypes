/****************************************************************************
 **
 ** Copyright (C) 2013-2014 Jolla Ltd.
 ** Contact: Bea Lam <bea.lam@jollamobile.com>
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.lipstick 0.1

BackgroundItem {
    id: root

    property string title: defaultTitle
    property bool expandable: true
    property bool inRemovableGroup
    property int animationDuration: 250

    //: Prompt to show more items in the notification group
    //% "Show more"
    property string defaultTitle: qsTrId("sailfish-components-lipstick-la-show-more")

    property real _expandedHeight: showMore.height + 2*Theme.paddingMedium

    property real contentLeftMargin: inRemovableGroup && Lipstick.compositor.eventsLayer.housekeeping
                                     ? (_deleteIconMargin + Theme.iconSizeMedium + _deleteIconMargin)
                                     : Theme.horizontalPageMargin

    property real _deleteIconMargin: Theme.paddingLarge


    opacity: expandable ? 1 : 0
    height: _expandedHeight * opacity

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

    Label {
        id: showMore

        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            left: parent.left
            leftMargin: root.contentLeftMargin
        }
        text: root.title
        font.pixelSize: Theme.fontSizeExtraSmall
        font.italic: true
        color: root.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }

    Image {
        anchors {
            verticalCenter: showMore.verticalCenter
            left: showMore.right
            leftMargin: Theme.paddingMedium
        }
        source: "image://theme/icon-lock-more?" + (root.highlighted ? Theme.highlightColor : Theme.primaryColor)
        width: Theme.iconSizeMedium * 0.7
        height: width
        sourceSize.width: width
    }
}
