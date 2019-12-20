import QtQuick 2.0
import Sailfish.Silica 1.0

ThumbnailImage {
    property alias duration: durationLabel.text
    property alias title: titleLabel.text

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height / 2
        opacity: Theme.opacityOverlay
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.highlightDimmerColor }
        }
    }

    Label {
        id: durationLabel

        font {
            pixelSize: Theme.fontSizeSmall
        }
        anchors {
            bottom: titleLabel.top; left: parent.left; leftMargin: Theme.paddingMedium
        }
    }

    Label {
        id: titleLabel

        font {
            pixelSize: Theme.fontSizeExtraSmall
        }
        color: Theme.highlightColor
        truncationMode: TruncationMode.Elide
        anchors {
            bottom: parent.bottom; bottomMargin: Theme.paddingMedium
            left: parent.left; leftMargin: Theme.paddingMedium
            right: parent.right
        }
    }
}
