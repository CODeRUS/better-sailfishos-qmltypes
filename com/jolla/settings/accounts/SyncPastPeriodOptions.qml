import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

ComboBox {
    id: root

    property AccountSyncOptions syncOptions

    // i.e. is a two-way sync, rather than a one-way download
    property bool isSync: true

    function _resetCurrentIndex() {
        if (!syncOptions) {
            return
        }
        // we map exactly to the enum values
        currentIndex = syncOptions.pastSyncPeriod
    }

    function _pastSyncPeriodText(period) {
        switch (period) {
        case AccountSyncOptions.OneDayAgo:
            //: Sync data from up to 1 day ago
            //% "1 day ago"
            return qsTrId("settings-accounts-me-sync_1_day_ago")
        case AccountSyncOptions.ThreeDaysAgo:
            //: Sync data from up to 3 days ago
            //% "3 days ago"
            return qsTrId("settings-accounts-me-sync_3_days_ago")
        case AccountSyncOptions.OneWeekAgo:
            //: Sync data from up to a week ago
            //% "1 week ago"
            return qsTrId("settings-accounts-me-sync_1_week_ago")
        case AccountSyncOptions.TwoWeeksAgo:
            //: Sync data from up to 2 weeks ago
            //% "2 weeks ago"
            return qsTrId("settings-accounts-me-sync_2_weeks_ago")
        case AccountSyncOptions.OneMonthAgo:
            //: Sync data from up to 1 month ago
            //% "1 month ago"
            return qsTrId("settings-accounts-me-sync_1_month_ago")
        }
        return ""
    }

    label: isSync
             //: Label for options allowing selection of the earliest time from which data should be synced. E.g. if "2 weeks" option is selected, data that is more than 2 weeks old will not be synced.
             //% "Sync events from"
           ? qsTrId("settings-accounts-la-sync_events_from")
             //: Label for options allowing selection of the earliest time from which data should be downloaded. E.g. if "2 weeks" option is selected, data that is more than 2 weeks old will not be downloaded.
             //% "Download events from"
           : qsTrId("settings-accounts-la-download_events_from")

    width: parent.width

    onSyncOptionsChanged: {
        _resetCurrentIndex()
    }

    Component.onCompleted: {
        _resetCurrentIndex()
    }

    onCurrentIndexChanged: {
        if (syncOptions) {
            syncOptions.pastSyncPeriod = pastSyncPeriodModel.get(currentIndex).period
        }
    }

    ListModel {
        id: pastSyncPeriodModel

        ListElement { period: AccountSyncOptions.OneDayAgo }
        ListElement { period: AccountSyncOptions.ThreeDaysAgo }
        ListElement { period: AccountSyncOptions.OneWeekAgo }
        ListElement { period: AccountSyncOptions.TwoWeeksAgo }
        ListElement { period: AccountSyncOptions.OneMonthAgo }
    }

    menu: ContextMenu {
        Repeater {
            model: pastSyncPeriodModel
            MenuItem { text: root._pastSyncPeriodText(model.period) }
        }
    }
}
