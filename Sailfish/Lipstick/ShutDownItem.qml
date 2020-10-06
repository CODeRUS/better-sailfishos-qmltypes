/*
 * Copyright (c) 2015 - 2020 Jolla Ltd.
 * Copyright (c) 2020 Open Moblie Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import org.nemomobile.systemsettings 1.0

Rectangle {
    id: shutDownItem

    property alias message: shutDownMessage.text
    property int mode
    property alias uid: user.uid

    color: "black"
    anchors.fill: parent
    Behavior on opacity {
        NumberAnimation {
            duration: 1000
            onRunningChanged: if (!running) opacityAnimationFinished()
        }
    }

    signal opacityAnimationFinished()

    UserInfo {
        id: user
    }

    Label {
        id: shutDownMessage

        anchors.centerIn: parent
        width: parent.width - 2 * Theme.horizontalPageMargin
        // Non themable color since we always want it white over black
        color: Theme.lightPrimaryColor
        font.pixelSize: Theme.fontSizeExtraLarge
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 5
        wrapMode: Text.Wrap
        textFormat: Text.AutoText
        text: {
            if (mode === ShutdownMode.Reboot) {
                //: Message shown when the device reboots
                //% "One moment..."
                return qsTrId("sailfish-components-lipstick-la-one-moment")
            } else if (mode === ShutdownMode.UserSwitch) {
                //: Message shown when user is switched, %1 is user's name
                //% "Switching to<br>%1..."
                return qsTrId("sailfish-components-lipstick-la-switching_user_with_name").arg(user.displayName)
            } else if (mode === ShutdownMode.UserSwitchFailed) {
                //: Message shown when user switch has failed
                //% "User switch failed"
                return qsTrId("sailfish-components-lipstick-la-switching_failed")
            } else if (user.name) {
                //: Message shown when the device turns off, %1 is user's name
                //% "Goodbye,<br>%1!"
                return qsTrId("sailfish-components-lipstick-la-goodbye_with_name").arg(user.name)
            } else {
                //: Message shown when the device turns off and user's name is unknown
                //% "Goodbye!"
                return qsTrId("sailfish-components-lipstick-la-goodbye")
            }
        }
    }
}
