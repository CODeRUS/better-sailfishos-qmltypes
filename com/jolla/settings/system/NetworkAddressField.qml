import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: networkAddressField

    property string icon
    property alias caption: fieldValue.label
    property alias text: fieldValue.text
    property alias readOnly: fieldValue.readOnly
    property alias placeholderText: fieldValue.placeholderText
    property bool wantHighlight: readOnly && (pressed || fieldValue.focus)
    property bool submitOnDefocus: false

    signal submit

    width: parent.width
    height: Theme.itemSizeLarge

    Image {
        id: imageIcon

        source: networkAddressField.icon + (networkAddressField.wantHighlight ? ("?" + Theme.highlightColor) : "")
        anchors {
            left: parent.left
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
    }

    TextField {
        id: fieldValue

        anchors {
            left: imageIcon.right
            leftMargin: Theme.paddingMedium
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        enabled: !readOnly
        color: networkAddressField.wantHighlight ? Theme.highlightColor : Theme.primaryColor

        EnterKey.onClicked: focus = false

        onFocusChanged: {
            if (networkAddressField.submitOnDefocus && !focus) {
                networkAddressField.submit()
            }
        }

        EnterKey.iconSource: "image://theme/icon-m-enter-close"
    }
}
