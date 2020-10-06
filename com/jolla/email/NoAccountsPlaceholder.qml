/*
 * Copyright (c) 2018 – 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Policy 1.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0

ViewPlaceholder {
    //: No accounts empty state
    //% "No accounts"
    text: qsTrId("email-la_no_accounts")
    hintText: AccessPolicy.accountCreationEnabled ?
            //: Pull down to add account hint text
            //% "Pull down to add an account"
            qsTrId("email-la_no_accounts_hint_text") :
            //: %1 is operating system name without OS suffix
            //% "Account creation disabled by %1 Device Manager"
            qsTrId("email-la-accounts_creation_disabled_by_device_manager")
                .arg(aboutSettings.baseOperatingSystemName)

    AboutSettings {
        id: aboutSettings
    }
}
