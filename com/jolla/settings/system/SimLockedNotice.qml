import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root

    signal continueClicked()

    Column {
        x: Theme.horizontalPageMargin
        y: Theme.itemSizeLarge
        width: parent.width - x*2
        spacing: Theme.paddingLarge

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeHuge
            }

            //: Heading displayed when SIM PIN & PUK has been entered incorrectly too many times.
            //% "SIM card locked permanently"
            text: qsTrId("settings_pin-he-SIM_locked_permanently")
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            //: Detailed information displayed when SIM PIN & PUK has been entered incorrectly too many times.
            //% "Contact your network service provider for a new SIM card. Until then you can continue to use the device without a network connection. Emergency calls are still possible without a SIM card."
            text: qsTrId("settings_pin-la-SIM_locked_permanently")
        }
    }

    Button {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        //% "Continue"
        text: qsTrId("settings_system-la-continue")

        onClicked: {
            root.continueClicked()
        }
    }
}
