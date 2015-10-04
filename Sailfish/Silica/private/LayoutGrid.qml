import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: layoutGrid

    property color color: Theme.highlightColor
    property int orientation: pageStack._currentOrientation
    property bool isLandscape: (orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted)

    z: 1000
    anchors.centerIn: parent
    width: rotatingItem.width
    height: rotatingItem.height
    rotation: rotatingItem.rotation

    PageHeader {
        id: pageHeader
        visible: false
        page: layoutGrid
    }
    Rectangle {
        // the bottom edge of page header area
        color: parent.color
        opacity: 0.4
        y: pageHeader.height
        height: Math.round(Theme.paddingSmall/3)
        width: parent.width
    }
    Rectangle {
        // horizontal center line
        color: parent.color
        opacity: 0.4
        anchors.verticalCenter: parent.verticalCenter
        height: Math.round(Theme.paddingSmall/3)
        width: parent.width
    }
    Rectangle {
        // vertical center line
        color: parent.color
        opacity: 0.4
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.round(Theme.paddingSmall/3)
        height: parent.height
    }
    Rectangle {
        // left page margin
        color: parent.color
        opacity: 0.6
        x: Theme.horizontalPageMargin
        width: Math.round(Theme.paddingSmall/3)
        height: parent.height
    }
    Rectangle {
        // right page margin
        color: parent.color
        opacity: 0.6
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        width: Math.round(Theme.paddingSmall/3)
        height: parent.height
    }
}
