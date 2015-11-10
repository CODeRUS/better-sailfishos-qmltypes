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

    property bool userRemovable
    property real iconCenterY

    property alias contentWidth: content.width
    property alias contentHeight: content.height
    property real contentLeftMargin: Theme.horizontalPageMargin

    property bool animateAddition: defaultAnimateAddition
    property bool animateRemoval: defaultAnimateRemoval

    // if the notification group has add/remove animations, it can animate the entire group
    // in/out when the first item is added or the last item is removed instead of running
    // the individual notification animation
    property bool defaultAnimateAddition: ListView.view.count > 0
    property bool defaultAnimateRemoval: ListView.view.count > 0

    property int animationDuration: 250
    property int pauseBeforeRemoval

    signal removeRequested
    signal triggered


    default property alias _content: content.data
    property Item _deleteIcon
    property real _deleteIconMargin: Theme.paddingLarge
    property real _animatedHeight: 1
    property real _animatedOpacity: 1
    property QtObject _addAnimation
    property QtObject _removeAnimation

    width: parent.width
    height: contentHeight * _animatedHeight
    highlighted: down && !Lipstick.compositor.eventsLayer.housekeeping

    // Fade out item in housekeeping mode, if not removable
    property real _baseOpacity: Lipstick.compositor.eventsLayer.housekeeping && !userRemovable ? 0.4 : 1.0
    opacity: _baseOpacity * _animatedOpacity

    Behavior on _baseOpacity {
        FadeAnimation {
            property: "_baseOpacity"
            duration: 200
        }
    }

    onUserRemovableChanged: {
        if (userRemovable && !_deleteIcon) {
            _deleteIcon = deleteIconComponent.createObject(root)
        }
    }

    ListView.onAdd: {
        if (!animateAddition) {
            return
        }
        if (!_addAnimation) {
            _addAnimation = addAnimationComponent.createObject(root)
        }
        _addAnimation.start()
    }
    ListView.onRemove: {
        if (!animateRemoval) {
            ListView.delayRemove = false
            return
        }
        if (!_removeAnimation) {
            _removeAnimation = removeAnimationComponent.createObject(root)
        }
        _removeAnimation.start()
    }
    ListView.delayRemove: true

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

    Component {
        id: deleteIconComponent

        IconButton {
            x: content.x - width - _deleteIconMargin
            y: root.iconCenterY - height/2
            enabled: Lipstick.compositor.eventsLayer.housekeeping && root.userRemovable
            opacity: enabled ? 1.0 : 0
            icon.source: "image://theme/icon-m-clear"
            width: icon.width
            height: width

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

    Item {
        id: content
        width: parent.width
        height: Theme.itemSizeSmall

        x:  Lipstick.compositor.eventsLayer.housekeeping && root.userRemovable
            ? (_deleteIconMargin + Theme.iconSizeMedium + _deleteIconMargin)
            : root.contentLeftMargin

        Behavior on x {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component {
        id: addAnimationComponent

        NotificationAddAnimation {
            target: root
            heightProperty: "_animatedHeight"
            opacityProperty: "_animatedOpacity"
            toHeight: 1
            animationDuration: root.animationDuration
        }
    }

    Component {
        id: removeAnimationComponent

        SequentialAnimation {
            PauseAnimation {
                duration: root.pauseBeforeRemoval
            }
            NotificationRemoveAnimation {
                target: root
                heightProperty: "_animatedHeight"
                opacityProperty: "_animatedOpacity"
                animationDuration: root.animationDuration
            }
            PropertyAction {
                target: root
                property: "ListView.delayRemove"
                value: false
            }
        }
    }
}
