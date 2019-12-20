/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

SimPinBackground {
    id: root

    readonly property int _maxSubcolumnWidth: parent.width - 2 * Theme.horizontalPageMargin

    signal continueClicked()

    width: parent.width
    height: parent.height

    Column {
        x: Theme.horizontalPageMargin
        y: Theme.itemSizeLarge
        width: parent.width - x*2
        spacing: Theme.paddingLarge

        Label {
            id: titleLabel
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Screen.sizeCategory > Screen.Medium ? Text.AlignHCenter
                                                                     : Text.AlignLeft
            color: Theme.rgba(Theme.highlightDimmerColor, Theme.opacityHigh)
            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeExtraLarge
            }

            //: Heading displayed when user has chosen not to enter the SIM PIN.
            //% "SIM card not in use"
            text: qsTrId("settings_system-he-SIM_not_in_use")
        }

        Column {
            spacing: Theme.paddingLarge
            x: Screen.sizeCategory > Screen.Medium ? (parent.width - width) / 2 : 0

            Label {
                width: Math.min(implicitWidth, _maxSubcolumnWidth)
                wrapMode: Text.Wrap
                color: Theme.highlightDimmerColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //: Network restriction information, displayed when user has chosen to bypass SIM PIN entry.
                //% "You won't be able to connect to the network. Only emergency calls are possible."
                text: qsTrId("settings_system-la-no_PIN_restrictions")
            }

            Label {
                width: Math.min(implicitWidth, _maxSubcolumnWidth)
                wrapMode: Text.Wrap
                color: Theme.highlightDimmerColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //: SIM unlocking instructions, displayed when user has chosen to bypass SIM PIN entry.
                //% "Your SIM card can still be unlocked later in Settings | Security | PIN code."
                text: qsTrId("settings_system-la-SIM_unlocking_instructions")
            }
        }
    }

    BackgroundItem {
        id: continueButton
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }

        onClicked: root.continueClicked()

        Label {
            anchors.centerIn: parent
            //% "Continue"
            text: qsTrId("settings_system-la-continue")
            color: continueButton.highlighted ? Theme.highlightColor : Theme.lightPrimaryColor
        }
    }
}
