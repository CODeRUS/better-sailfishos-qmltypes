import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: detailItem

    property alias detailValue: contactDetailValue.text
    property alias detailTypeValue: contactDetailType.text
    property real activationProgress

    property alias expandingContent: contactDetailActions.data
    property alias active: contactDetailActions.active
    property bool _wasActive

    // Signal that tells that the header needs to be opened/closed.
    signal contactDetailClicked(variant detailItem)

    width: parent.width

    onActiveChanged: _wasActive = !active
    onActivationProgressChanged: {
        if (activationProgress == 1) {
            _wasActive = false
        }
    }

    MouseArea {
        id: ma

        width: parent.width
        height: contactDetailActions.y + contactDetailActions.height

        onClicked: contactDetailClicked(detailItem)

        Item {
            id: labelWrapper

            property bool active: contactDetailActions.active || (ma.pressed && ma.containsMouse)

            width: parent.width
            height: childrenRect.height

            Label {
                id: contactDetailType
                color: parent.active ? Theme.highlightColor : Theme.primaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeLarge
                }
            }

            Label {
                id: contactDetailValue
                color: parent.active ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                y: contactDetailType.y + contactDetailType.height - Theme.paddingSmall // TODO: Stupid font marginals.
                width: parent.width - 2*Theme.paddingSmall
                x: Theme.paddingSmall
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        Column {
            id: contactDetailActions

            property bool active
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelWrapper.bottom
                topMargin: Theme.paddingMedium
            }

            property real animationProgress: active ? activationProgress : (_wasActive ? (1 - activationProgress) : 0)

            height: implicitHeight * animationProgress
            opacity: 1 * animationProgress
        }
    }
}
