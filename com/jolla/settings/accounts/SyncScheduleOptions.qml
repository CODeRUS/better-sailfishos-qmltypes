import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

ValueButton {
    id: root

    property AccountSyncSchedule schedule
    property IntervalListModel intervalModel: IntervalListModel { }
    property bool isSync
    property bool isAlwaysOn
    property bool showAlwaysOn

    //: Only sync when user manually requests it; do not sync automatically
    //% "Manually"
    property string _textManual: qsTrId("settings-accounts-la-sync_manually")

    //: Show custom options for data syncing
    //% "Custom"
    property string _textCustom: qsTrId("settings-accounts-la-sync_custom")

    //: Always up to date schedule
    //% "Always up-to-date"
    property string _textAlwaysOn: qsTrId("settings-accounts-la-sync_always_on")

    signal alwaysOnChanged(bool state)

    // Property assignment can happen after Component.onCompleted
    onIsAlwaysOnChanged: {
        if (isAlwaysOn && value != _textAlwaysOn) {
            value = _textAlwaysOn
        }
    }

    function _optionClicked() {
        _resetValueText()
        pageStack.pop()
    }

    function _resetValueText() {
        if (!schedule) {
            return
        }
        if (isAlwaysOn) {
            value = _textAlwaysOn
        } else if (!schedule.enabled) {
            value = _textManual
        } else if (schedule.peakScheduleEnabled) {
            value = _textCustom
        } else {
            value = intervalModel.intervalText(schedule.interval)
        }
    }

    function setInterval(interval) {
        if (!schedule) {
            return
        }
        if (interval === AccountSyncSchedule.NoInterval) {
            schedule.enabled = false
            schedule.peakScheduleEnabled = false
        } else {
            schedule.enabled = true
        }
        schedule.setIntervalSyncMode(interval)
        _resetValueText()
    }

    label: isSync
             //: Click to show options on how often content should be synced with the server
             //% "Sync content"
           ? qsTrId("settings-accounts-la-sync_content")
             //: Click to show options on how often new content should be downloaded from the server
             //% "Download new content"
           : qsTrId("settings-accounts-la-download_new_content")

    onClicked: {
        pageStack.push(optionsComponent)
    }

    onScheduleChanged: {
        // If the schedule uses a daily sync time rather than an interval, force
        // it to use an interval instead, since the UI doesn't allow a daily sync
        // time to be used.
        if (isNaN(schedule.dailySyncTime)) {
            schedule.setIntervalSyncMode(AccountSyncSchedule.TwiceDailyInterval)
        }
        _resetValueText()
    }

    Component.onCompleted: {
        _resetValueText()
    }

    Component {
        id: optionsComponent
        Page {
            Column {
                width: parent.width

                PageHeader {
                    //: Heading for page that allows the data sync schedule to be changed
                    //% "Schedule"
                    title: qsTrId("settings-accounts-he-schedule")
                }

                ListItem {
                    width: parent.width
                    visible: root.showAlwaysOn
                    onClicked: {
                        root.schedule.enabled = false
                        root.schedule.peakScheduleEnabled = false
                        if (!root.isAlwaysOn) {
                            root.alwaysOnChanged(true);
                        }
                        root._optionClicked()
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
                    width: parent.width
                    intervalModel: root.intervalModel
                    onIntervalClicked: {
                        root.schedule.enabled = true
                        root.schedule.setIntervalSyncMode(accountSyncInterval)
                        root.schedule.peakScheduleEnabled = false
                        if (root.isAlwaysOn) {
                            root.alwaysOnChanged(false);
                        }
                        root._optionClicked()
                    }
                }

                ListItem {
                    width: root.width
                    onClicked: {
                        root.schedule.enabled = false
                        root.schedule.peakScheduleEnabled = false
                        if (root.isAlwaysOn) {
                            root.alwaysOnChanged(false);
                        }
                        root._optionClicked()
                    }

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: Theme.horizontalPageMargin
                        }
                        text: root._textManual
                    }
                }

                ListItem {
                    width: root.width
                    onClicked: {
                        root.schedule.enabled = true
                        root.schedule.setIntervalSyncMode(AccountSyncSchedule.Every15Minutes)   // off-peak settings
                        root.schedule.setDefaultPeakSchedule()
                        root.schedule.peakScheduleEnabled = true
                        if (root.isAlwaysOn) {
                            root.alwaysOnChanged(false);
                        }
                        root._optionClicked()
                    }

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: Theme.horizontalPageMargin
                        }
                        text: root._textCustom
                    }
                }
            }
        }
    }
}
