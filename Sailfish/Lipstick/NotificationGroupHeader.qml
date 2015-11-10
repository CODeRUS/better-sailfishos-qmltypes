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

    property alias name: nameLabel.text
    property alias indicator: notifIndicator
    property int memberCount
    property int totalItemCount

    property bool showName: true
    property bool showTotalItemCount: true
    property bool userRemovable: true
    property int animationDuration: 250

    signal removeRequested
    signal triggered


    property bool _showGroupDeleteIcon: userRemovable && memberCount > 1
    property real _deleteIconMargin: Theme.paddingLarge

    height: Theme.fontSizeLarge + Theme.paddingSmall * 2 + Theme.paddingMedium
    highlighted: down && !Lipstick.compositor.eventsLayer.housekeeping

    onPressed: {
        if (Lipstick.compositor.eventsLayer.housekeeping) {
            mouse.accepted = false
        }
    }

    onPressAndHold: {
        Lipstick.compositor.eventsLayer.toggleHousekeeping()
    }

    onClicked: {
        if (Lipstick.compositor.eventsLayer.housekeeping) {
            Lipstick.compositor.eventsLayer.setHousekeeping(false)
            return
        }
        root.triggered()
    }

    Item {
        id: groupHeaderLayout

        width: root.width
        height: parent.height

        // Fade out item in housekeeping mode, if not removable
        opacity: Lipstick.compositor.eventsLayer.housekeeping && !root.userRemovable ? 0.4 : 1.0
        Behavior on opacity {
            FadeAnimation { duration: 200 }
        }

        NotificationIndicator {
            id: notifIndicator

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            count: root.totalItemCount
            showCount: root.showTotalItemCount && count > 1
            highlighted: root.highlighted
        }

        Label {
            id: nameLabel

            anchors {
                right: notifIndicator.left
                rightMargin: Theme.paddingMedium
                verticalCenter: notifIndicator.verticalCenter
            }
            width: {
                var leftMargin = 0
                if (Lipstick.compositor.eventsLayer.housekeeping && root._showGroupDeleteIcon) {
                    // This left margin should indent the horizontal centre of the group delete icon
                    // to the child-item label offset position.
                    var housekeepingMemberLabelOffset = (_deleteIconMargin + deleteGroupIcon.width/2 + _deleteIconMargin)
                    leftMargin = housekeepingMemberLabelOffset + deleteGroupIcon.width + _deleteIconMargin
                } else {
                    leftMargin = Theme.horizontalPageMargin
                }
                var overheadWidth = leftMargin + anchors.rightMargin + notifIndicator.width
                return Math.min(implicitWidth, parent.width - overheadWidth)
            }
            textFormat: Text.PlainText
            maximumLineCount: 1
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeMedium
            color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
            opacity: root.showName ? 1 : 0

            Behavior on opacity {
                FadeAnimation {}
            }
        }

        IconButton {
            id: deleteGroupIcon
            x: {
                var xOffset = width + _deleteIconMargin + nameLabel.width + nameLabel.anchors.rightMargin + notifIndicator.width
                if (!Lipstick.compositor.eventsLayer.housekeeping) {
                    // use animation distance consistent with delete icons of member items, instead of possibly travelling further
                    xOffset += (width + _deleteIconMargin)
                }
                return parent.width - xOffset
            }
            anchors.verticalCenter: notifIndicator.verticalCenter
            enabled: Lipstick.compositor.eventsLayer.housekeeping && root._showGroupDeleteIcon
            opacity: enabled ? 1.0 : 0
            icon.source: "image://theme/icon-m-clear"
            width: icon.width
            height: width

            Behavior on x {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on opacity {
                FadeAnimation {
                    duration: root.animationDuration
                }
            }

            onClicked: {
                root.removeRequested()
            }
        }
    }
}
