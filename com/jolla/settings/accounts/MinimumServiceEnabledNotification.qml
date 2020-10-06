/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import Nemo.Notifications 1.0

Notification {
    icon: "icon-lock-warning"
    isTransient: true

    //% "At least one service must be enabled"
    previewSummary: qsTrId("settings-accounts-la-enable_at_least_one_service")
}
