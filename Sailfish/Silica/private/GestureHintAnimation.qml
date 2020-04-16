import QtQuick 2.6
import Sailfish.Silica 1.0

SequentialAnimation {
    id: root

    property Item target
    property string property
    property int amplitude: Theme.paddingSmall
    loops: Animation.Infinite
    alwaysRunToEnd: true
    NumberAnimation {
        target: root.target
        property: root.property
        from: 0.0
        to: -amplitude
        duration: 150
        easing.type: Easing.OutQuad
    }
    NumberAnimation {
        target: root.target
        property: root.property
        from: -amplitude
        to: amplitude
        duration: 300
        easing.type: Easing.InOutQuad
    }
    NumberAnimation {
        target: root.target
        property: root.property
        from: amplitude
        to: 0
        duration: 150
        easing.type: Easing.InQuad
    }
}
