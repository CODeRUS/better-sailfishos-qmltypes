import QtQuick 2.2
import org.nemomobile.systemsettings 1.0
import Sailfish.Silica 1.0
import Sailfish.Secrets 1.0 as Secrets

Column {
    property QtObject secrets

    width: parent.width
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation {}}

    SectionHeader {
        //% "Master lock"
        text: qsTrId("secrets_ui-he-enter-master-lock-info")
    }

    BatteryStatus {
        id: batteryStatus

        readonly property bool batteryOk: status >= BatteryStatus.Normal || chargerStatus == BatteryStatus.Connected
    }

    Label {
        visible: secrets.masterLocked || !batteryStatus.batteryOk
        x: Theme.horizontalPageMargin
        width: parent.width - x * 2
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall

        text: {
            if (secrets.masterLocked) {
                //% "Enter master lock code to unlock keys."
                return qsTrId("secrets_ui-la-enter-master-lock-info")
            } else if (!batteryStatus.batteryOk) {
                return batteryStatus.chargerStatus == BatteryStatus.Connected ?
                            //: Battery low for changing master lock code when charger is attached.
                            //% "Battery level low. Do not remove the charger."
                            qsTrId("secrets_ui-la-battery_charging") :
                            //: Battery low for changing master lock code.
                            //% "Battery level too low."
                            qsTrId("secrets_ui-la-battery_level_low")

            }
            return ""
        }
    }

    Item {
        width: 1
        height: Theme.paddingLarge
    }

    Button {
        id: masterUnlockButton
        // Consider battery status only when master lock is unlocked.
        visible: secrets.masterLocked || batteryStatus.batteryOk
        enabled: !secrets.busy
        text: secrets.masterLocked ?
                  //: Unlock is shown under master lock section. Thus, no need to repeat master lock here.
                  //% "Unlock"
                  qsTrId("secrets_ui-bt-unlock_master_lock_code") :
                  //: Change code is shown under master lock section. Thus, no need to repeat master lock here.
                  //% "Change code"
                  qsTrId("secrets_ui-bt-change_master_lock_code")
        anchors.horizontalCenter: parent.horizontalCenter
        preferredWidth: Theme.buttonWidthMedium

        onClicked: {
            secrets.masterLockCodeRequest(secrets.masterLocked ? Secrets.LockCodeRequest.ProvideLockCode : Secrets.LockCodeRequest.ModifyLockCode)
        }
    }

    Item {
        visible: masterUnlockButton.visible
        width: 1
        height: Theme.paddingLarge
    }

    // TODO: This should be only visible when operating master lock.
    BusyPlaceholder {
        active: secrets.busy
        height: opacity * implicitHeight
    }
}
