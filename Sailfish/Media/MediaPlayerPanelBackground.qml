import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    gradient: Gradient {
        GradientStop { position: 0.0; color: "transparent" }
        GradientStop { position: 0.7; color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) }
    }
}
