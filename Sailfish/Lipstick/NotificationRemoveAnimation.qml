/****************************************************************************
 **
 ** Copyright (C) 2015 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.lipstick 0.1

ParallelAnimation {
    id: root

    property Item target
    property string heightProperty: "height"
    property string opacityProperty: "opacity"
    property alias fromHeight: heightAnimation.from
    property int animationDuration: Desktop.eventsViewVisible ? 200 : 0

    NumberAnimation {
        id: heightAnimation

        target: root.target
        property: root.heightProperty
        to: 0
        duration: root.animationDuration
        easing.type: Easing.InOutQuad
    }
    SequentialAnimation {
        NumberAnimation {
            target: root.target
            property: root.opacityProperty
            from: 1
            to: 0
            duration: root.animationDuration*2/3
        }
        NumberAnimation {
            target: root.target
            property: root.opacityProperty
            from: 0
            to: 0
            duration: root.animationDuration*1/3
        }
    }
}
