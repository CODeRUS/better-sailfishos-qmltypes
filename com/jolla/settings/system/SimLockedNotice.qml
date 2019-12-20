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

            //: Heading displayed when SIM PIN & PUK has been entered incorrectly too many times.
            //% "SIM card locked permanently"
            text: qsTrId("settings_pin-he-SIM_locked_permanently")
        }

        Label {
            id: textLabel
            x: Screen.sizeCategory > Screen.Medium ? (parent.width - width) / 2 : 0
            width: Math.min(implicitWidth, parent.width)
            wrapMode: Text.Wrap
            color: Theme.highlightDimmerColor
            font.pixelSize: Theme.fontSizeExtraSmall
            //: Detailed information displayed when SIM PIN & PUK has been entered incorrectly too many times.
            //% "Contact your network service provider for a new SIM card. Until then you can continue to use the device without a network connection. Emergency calls are still possible without a SIM card."
            text: qsTrId("settings_pin-la-SIM_locked_permanently")
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
