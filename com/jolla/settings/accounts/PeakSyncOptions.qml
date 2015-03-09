import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Column {
    id: root

    property AccountSyncSchedule schedule
    property IntervalListModel intervalModel: IntervalListModel { }

    property int peakInterval: schedule ? schedule.peakInterval : 0
    property int offPeakInterval: schedule ? schedule.interval : 0
    property var peakStartTime: schedule ? schedule.peakStartTime : null
    property var peakEndTime: schedule ? schedule.peakEndTime : null
    property int peakDays: schedule ? schedule.peakDays : 0

    function _updateSchedule() {
        if (schedule) {
            schedule.peakScheduleEnabled = true
            schedule.setIntervalSyncMode(offPeakInterval)
            schedule.setPeakSchedule(peakStartTime, peakEndTime, peakInterval, peakDays)
        }
    }

    width: parent ? parent.width : 0
    height: childrenRect.height

    ValueButton {
        //: Peak interval for data sync (e.g. user can click to choose to sync every 15 minutes, every hour, etc.) during designated peak period
        //% "Peak interval"
        label: qsTrId("settings-accounts-la-peak_interval")
        value: root.intervalModel.intervalText(root.peakInterval)
        onClicked: {
            var obj = pageStack.push(intervalPickerDialog)
            obj.intervalClicked.connect(function(interval, text) {
                root.peakInterval = interval
                root._updateSchedule()
            })
        }
    }

    ValueButton {
        //: Peak interval for data sync (e.g. user can click to choose to sync every 15 minutes, every hour, etc.) during designated off-peak period
        //% "Off-peak interval"
        label: qsTrId("settings-accounts-la-off_peak_interval")
        value: root.intervalModel.intervalText(root.offPeakInterval)
        onClicked: {
            var obj = pageStack.push(intervalPickerDialog)
            obj.intervalClicked.connect(function(interval, text) {
                root.offPeakInterval = interval
                root._updateSchedule()
            })
        }
    }

    ValueButton {
        //: Time at which to start the peak period for syncing data
        //% "Peak time starts"
        label: qsTrId("settings-accounts-la-peak_start")
        value: Format.formatDate(root.peakStartTime, Format.TimeValue)
        onClicked: {
            var obj = pageStack.push(timePickerDialog,
                    {"hour": root.peakStartTime.getHours(), "minute": root.peakStartTime.getMinutes() })
            obj.accepted.connect(function() {
                root.peakStartTime = obj.time
                root._updateSchedule()
            })
        }
    }

    ValueButton {
        //: Time at which to finish the peak period for syncing data
        //% "Peak time ends"
        label: qsTrId("settings-accounts-la-peak_end")
        value: Format.formatDate(root.peakEndTime, Format.TimeValue)
        onClicked: {
            var obj = pageStack.push(timePickerDialog,
                    {"hour": root.peakEndTime.getHours(), "minute": root.peakEndTime.getMinutes() })
            obj.accepted.connect(function() {
                root.peakEndTime = obj.time
                root._updateSchedule()
            })
        }
    }

    Label {
        //: Label above section allowing selection of the days on which "peak" sync should be applicable
        //% "Peak days"
        text: qsTrId("settings-accounts-la-peak_days")
        x: Theme.paddingLarge
        height: implicitHeight + Theme.paddingMedium    // extra space between the label and the combo above
        verticalAlignment: Text.AlignBottom
    }

    WeekDaySelector {
        id: weekDaySelector
        width: parent.width
        weekDaysField: root.peakDays

        onWeekDaysFieldChanged: {
            root.peakDays = weekDaysField
            root._updateSchedule()
        }
    }

    Item {
        width: 1
        height: Theme.paddingLarge
    }

    Component {
        id: intervalPickerDialog
        Page {
            id: intervalPickerPage
            signal intervalClicked(int accountSyncInterval, string intervalText)

            PageHeader {
                id: pageHeader
                //: Heading for page that allows the data sync schedule to be changed
                //% "Schedule"
                title: qsTrId("settings-accounts-he-schedule")
            }
            SyncIntervalOptions {
                anchors.top: pageHeader.bottom
                intervalModel: root.intervalModel
                onIntervalClicked: {
                    intervalPickerPage.intervalClicked(accountSyncInterval, intervalText)
                    pageStack.pop()
                }
            }
        }
    }

    Component {
        id: timePickerDialog
        TimePickerDialog { }
    }
}
