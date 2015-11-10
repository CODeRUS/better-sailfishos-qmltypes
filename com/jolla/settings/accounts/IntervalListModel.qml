import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

ListModel {
    id: optionsModel

    function intervalText(accountSyncInterval) {
        switch (accountSyncInterval) {
        case AccountSyncSchedule.Every5Minutes:
            //: Sync data every 5 minutes
            //% "Every 5 minutes"
            return qsTrId("settings-accounts-me-sync_every_5_min")
        case AccountSyncSchedule.Every15Minutes:
            //: Sync data every 15 minutes
            //% "Every 15 minutes"
            return qsTrId("settings-accounts-me-sync_every_15_min")
        case AccountSyncSchedule.Every30Minutes:
            //: Sync data every 30 minutes
            //% "Every 30 minutes"
            return qsTrId("settings-accounts-me-sync_every_30_min")
        case AccountSyncSchedule.EveryHour:
            //: Sync data every hour
            //% "Every hour"
            return qsTrId("settings-accounts-me-sync_every_hour")
        case AccountSyncSchedule.TwiceDailyInterval:
            //: Sync data twice a day
            //% "Twice a day"
            return qsTrId("settings-accounts-me-sync_twice_a_day")
        case AccountSyncSchedule.NoInterval:
            //: Only sync when user manually requests it; do not sync automatically
            //% "Manually"
            return qsTrId("settings-accounts-me-sync_manually")
        }
        return ""
    }

    ListElement { interval: AccountSyncSchedule.Every15Minutes }
    ListElement { interval: AccountSyncSchedule.Every30Minutes }
    ListElement { interval: AccountSyncSchedule.EveryHour }
    ListElement { interval: AccountSyncSchedule.TwiceDailyInterval }
}
