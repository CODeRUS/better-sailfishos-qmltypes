import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root

    property real fadeOpacity: Theme.opacityHigh
    property bool topDown

    color: "black"
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: Theme.rgba(root.color, topDown ? fadeOpacity : 0.0 )
        }
        GradientStop {
            position: topDown ? 0.2 : 0.8
            color: Theme.rgba(root.color, fadeOpacity)
        }
        GradientStop {
            position: 1.0
            color: Theme.rgba(root.color, topDown ? 0.0 : fadeOpacity)
        }
    }
}

