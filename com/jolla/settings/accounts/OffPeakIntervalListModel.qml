import QtQuick 2.0
import Sailfish.Accounts 1.0

IntervalListModel {
    Component.onCompleted: {
        append({"interval": AccountSyncSchedule.NoInterval})
    }
}
