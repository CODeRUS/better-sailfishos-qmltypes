import QtQuick 2.0
import Sailfish.Accounts 1.0

OffPeakIntervalListModel {
    Component.onCompleted: {
        insert(0, {"interval": AccountSyncSchedule.Every5Minutes})
    }
}
