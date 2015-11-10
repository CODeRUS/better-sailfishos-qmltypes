/****************************************************************************
 **
 ** Copyright (C) 2015 Jolla Ltd.
 ** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

ParallelAnimation {
    id: root

    property Item target
    property string heightProperty: "height"
    property string opacityProperty: "opacity"
    property alias toHeight: heightAnimation.to
    property int animationDuration: 400

    NumberAnimation {
        id: heightAnimation

        target: root.target
        property: root.heightProperty
        from: 0
        duration: root.animationDuration
        easing.type: Easing.InOutQuad

        onToChanged: {
            if (root.running) {
                root.restart()
            }
        }
    }

    SequentialAnimation {
        NumberAnimation {
            target: root.target
            property: root.opacityProperty
            from: 0
            to: 0
            duration: root.animationDuration*1/3
        }
        NumberAnimation {
            target: root.target
            property: root.opacityProperty
            from: 0
            to: 1
            duration: root.animationDuration*2/3
        }
    }
}
