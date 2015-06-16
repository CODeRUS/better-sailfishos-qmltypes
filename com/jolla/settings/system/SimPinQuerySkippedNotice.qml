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
            opacity: 0.6
            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeHuge
            }

            //: Heading displayed when user has chosen not to enter the SIM PIN.
            //% "SIM card not in use"
            text: qsTrId("settings_system-he-SIM_not_in_use")
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraSmall
            //: Network restriction information, displayed when user has chosen to bypass SIM PIN entry.
            //% "You won't be able to connect to the network. Only emergency calls are possible."
            text: qsTrId("settings_system-la-no_PIN_restrictions")
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraSmall
            //: SIM activation instructions, displayed when user has chosen to bypass SIM PIN entry.
            //% "Your SIM card can still be activated later in Settings > System settings > PIN code."
            text: qsTrId("settings_system-la-SIM_activation_instructions")
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
