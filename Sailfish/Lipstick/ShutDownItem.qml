/****************************************************************************
 **
 ** Copyright (C) 2015 Jolla Ltd.
 ** Contact: Andres Gomez <andres.gomez@jolla.com>
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: shutDownItem

    property alias message: shutDownMessage.text
    property string userName
    property bool rebooting

    color: "black"
    anchors.fill: parent
    Behavior on opacity {
        NumberAnimation {
            duration: 1000
            onRunningChanged: if (!running) opacityAnimationFinished()
        }
    }

    signal opacityAnimationFinished()

    Label {
        id: shutDownMessage
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.horizontalPageMargin
        // Non themable color since we always want it white over black
        color: "white"
        font.pixelSize: Theme.fontSizeExtraLarge
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: rebooting
              //: Message shown when the device reboots
              //% "One moment..."
              ? qsTrId("sailfish-components-lipstick-la-one-moment")
              : shutDownItem.userName !== ""
                //: Shut down message
                //% "Goodbye %1!"
                ? qsTrId("sailfish-components-lipstick-la-goodbye-user").arg(shutDownItem.userName)
                //% "Goodbye!"
                : qsTrId("sailfish-components-lipstick-la-goodbye")
    }
}
