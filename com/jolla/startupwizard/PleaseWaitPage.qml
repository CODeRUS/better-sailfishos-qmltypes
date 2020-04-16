/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

Page {
    id: root

    property string localeName
    property alias waiting: busyIndicator.running
    property int encryptionStatus
    property StartupWizardManager startupWizardManager

    signal waitingStopped

    Label {
        id: startLabel

        horizontalAlignment: Text.AlignHCenter
        width: parent.width - Theme.horizontalPageMargin*2
        wrapMode: Text.Wrap
        textFormat: Text.StyledText // render <br>
        opacity: busyIndicator.opacity

        text: {
            switch (encryptionStatus) {
            case 3: // EncryptionStatus.Error:
                //: Shown when user data encryption failed
                //% "User data encryption failed"
                qsTrId("startupwizard-la-user_data_encryption_failed") // trigger Qt Linguist translation
                return startupWizardManager.translatedText("startupwizard-la-user_data_encryption_failed", root.localeName)
            case 1: // EncryptionStatus.Busy:
            case 2: // EncryptionStatus.Encrypted:
                //% "Encrypting user data,<br>please wait"
                qsTrId("startupwizard-la-finalizing_user_data_encryption") // trigger Qt Linguist translation
                return startupWizardManager.translatedText("startupwizard-la-finalizing_user_data_encryption", root.localeName)
            case 0: // EncryptionStatus.Idle:
            default:
                //: Shown when Sailfish OS is starting up
                //% "Starting,<br>please wait"
                qsTrId("startupwizard-la-starting_sailfish_please_wait") // trigger Qt Linguist translation
                return startupWizardManager.translatedText("startupwizard-la-starting_sailfish_please_wait", root.localeName)
            }
        }
        font.pixelSize: Theme.fontSizeExtraLarge
        color: startupWizardManager.defaultHighlightColor()

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: busyIndicator.bottom
            topMargin: Theme.paddingLarge
        }
    }

    BusyIndicator {
        id: busyIndicator

        readonly property bool waited: !running && opacity == 0.0
        onWaitedChanged: if (waited) root.waitingStopped()

        running: true
        y: Math.round(parent.height/4)
        size: BusyIndicatorSize.Large
        color: startLabel.color
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        opacity: busyIndicator.opacity
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height/8
            horizontalCenter: parent.horizontalCenter
        }
        source: "image://theme/icon-os-state-update?" + startupWizardManager.defaultHighlightColor()
    }
}
