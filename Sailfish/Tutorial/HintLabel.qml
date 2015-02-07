import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias text: label.text
    property bool atBottom
    property alias showGradient: gradientRect.visible
    property alias opacityFadeDuration: fadeAnimation.duration
    property alias _label: label

    anchors.fill: parent

    Rectangle {
        width: parent.width
        height: showGradient
                ? label.height + 4 * Theme.paddingLarge
                : parent.height
        y: atBottom ? parent.height - height : 0
        color: Theme.rgba(tutorialTheme.highlightDimmerColor, 0.9)
    }

    Rectangle {
        id: gradientRect
        width: parent.width
        height: 3 * Theme.itemSizeLarge
        anchors {
            verticalCenter: atBottom ? label.top : label.bottom
            verticalCenterOffset: atBottom ? -height / 2 : height / 2
        }
        gradient: Gradient {
            GradientStop {
                position: atBottom ? 0.0 : 1.0
                color: "transparent"
            }
            GradientStop {
                position: atBottom ? 1.0 : 0.0
                color: Theme.rgba(tutorialTheme.highlightDimmerColor, 0.9)
            }
        }
    }

    InfoLabel {
        id: label
        y: atBottom
           ? parent.height - height - 4 * Theme.paddingLarge
           : 4 * Theme.paddingLarge
        color: tutorialTheme.highlightColor
    }

    Behavior on opacity {
        FadeAnimation {
            id: fadeAnimation
            duration: 1000
        }
    }
}
