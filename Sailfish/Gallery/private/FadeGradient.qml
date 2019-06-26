import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    property real fadeOpacity: 0.6
    property bool topDown
    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, topDown ? fadeOpacity : 0.0 ) }
        GradientStop { position: topDown ? 0.2 : 0.8; color: Qt.rgba(0, 0, 0, fadeOpacity ) }
        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, topDown ? 0.0 : fadeOpacity) }
    }
}
