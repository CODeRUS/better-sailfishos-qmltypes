import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Column {
    id: root

    property AccountSyncSchedule schedule
    property IntervalListModel intervalModel: IntervalListModel { }
    property IntervalListModel offPeakIntervalModel: IntervalListModel {
        Component.onCompleted: {
            append({"interval": AccountSyncSchedule.NoInterval})
        }
    }

    property int peakInterval: schedule ? schedule.peakInterval : 0
    property int offPeakInterval: schedule ? schedule.interval : 0
    property var peakStartTime: schedule ? schedule.peakStartTime : null
    property var peakEndTime: schedule ? schedule.peakEndTime : null
    property int peakDays: schedule ? schedule.peakDays : 0
    property bool alwaysOnPeak: schedule ? schedule.syncExternallyDuringPeak : 0
    property bool showAlwaysOn

    //: Always up to date schedule
    //% "Always up-to-date"
    property string _textAlwaysOn: qsTrId("settings-accounts-la-sync_always_on")

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
        value: root.alwaysOnPeak ? _textAlwaysOn : root.intervalModel.intervalText(root.peakInterval)
        onClicked: {
            var obj = pageStack.push(intervalPickerDialog, {"showAlwaysOn": showAlwaysOn, "intervalModel": root.intervalModel})
            obj.intervalClicked.connect(function(interval, text) {
                root.peakInterval = interval
                if (text == _textAlwaysOn) {
                    schedule.syncExternallyDuringPeak = true
                } else {
                    schedule.syncExternallyDuringPeak = false
                }
                root._updateSchedule()
            })
        }
    }

    ValueButton {
        //: Peak interval for data sync (e.g. user can click to choose to sync every 15 minutes, every hour, etc.) during designated off-peak period
        //% "Off-peak interval"
        label: qsTrId("settings-accounts-la-off_peak_interval")
        value: root.offPeakIntervalModel.intervalText(root.offPeakInterval)
        onClicked: {
            var obj = pageStack.push(intervalPickerDialog, {"intervalModel": root.offPeakIntervalModel})
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
        x: Theme.horizontalPageMargin
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
            property bool showAlwaysOn
            property var intervalModel
            signal intervalClicked(int accountSyncInterval, string intervalText)

            Column {
                width: parent.width

                PageHeader {
                    id: pageHeader
                    //: Heading for page that allows the data sync schedule to be changed
                    //% "Schedule"
                    title: qsTrId("settings-accounts-he-schedule")
                }

                ListItem {
                    width: parent.width
                    visible: intervalPickerPage.showAlwaysOn
                    onClicked: {
                        intervalPickerPage.intervalClicked(0, _textAlwaysOn)
                        pageStack.pop()
                    }

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: Theme.horizontalPageMargin
                        }
                        text: _textAlwaysOn
                    }
                }

                SyncIntervalOptions {
                    intervalModel: intervalPickerPage.intervalModel
                    onIntervalClicked: {
                        intervalPickerPage.intervalClicked(accountSyncInterval, intervalText)
                        pageStack.pop()
                    }
                }
            }
        }
    }

    Component {
        id: timePickerDialog
        TimePickerDialog { }
    }
}
