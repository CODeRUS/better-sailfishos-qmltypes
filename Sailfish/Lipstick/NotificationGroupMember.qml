/****************************************************************************
 **
 ** Copyright (C) 2013-2015 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.Background 1.0

NotificationBaseItem {
    id: root

    property bool animateAddition: defaultAnimateAddition
    property bool animateRemoval: defaultAnimateRemoval

    // if the notification group has add/remove animations, it can animate the entire group
    // in/out when the first item is added or the last item is removed instead of running
    // the individual notification animation
    property bool defaultAnimateAddition: ListView.view.count > 0
    property bool defaultAnimateRemoval: ListView.view.count > 0

    property int pauseBeforeRemoval

    property real _animatedHeight: 1
    property QtObject _addAnimation
    property QtObject _removeAnimation
    property bool lastItem

    width: parent.width
    height: contentHeight * _animatedHeight
    contentHeight: Theme.itemSizeSmall

    roundedCorners: lastItem ? Corners.BottomLeft | Corners.BottomRight
                             : Corners.None

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

    Component {
        id: addAnimationComponent

        NotificationAddAnimation {
            target: root
            heightProperty: "_animatedHeight"
            opacityProperty: "_animatedOpacity"
            toHeight: 1
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
                animationDuration: 200
            }
            PropertyAction {
                target: root
                property: "ListView.delayRemove"
                value: false
            }
        }
    }
}
