/**
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Messages 1.0
import com.jolla.settings.system 1.0

DisabledByMdmBanner {
    property string localUid
    active: MessageUtils.isSMS(localUid) && !MessageUtils.messagingPermitted
    clip: true
    color: "transparent"
    compressed: true
    //: Banner shown to the user when they are missing permission to send SMS or MMS
    //% "You cannot send SMS messages. It is disabled by user permissions."
    text: qsTrId("messages-la-no_user_permission")
}
