import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

Page {
    backNavigation: false
    opacity: status === PageStatus.Active ? 1.0 : 0.0

    signal lockCodeConfirmed(string enteredPin)

    DeviceLockInterface {
        id: deviceLock
    }

    DeviceLockInput {
        id: devicelockinput

        //% "Confirm with lock code"
        titleText: qsTrId("settings_devicelock-he-lock_code_confirm_title")
        //% "Confirm"
        okText: qsTrId("settings_devicelock-bt-devicelock_confirm")

        showEmergencyButton: false

        onPinEntryCanceled: {
            clear()
            pageStack.pop()
        }

        onPinConfirmed: {
            if (deviceLock.checkCode(enteredPin)) {
                lockCodeConfirmed(enteredPin)
            } else {
                // could use same id as devicelock, but avoiding for now due to lupdate picking
                // source only from first encountered use
                //% "Incorrect lock code"
                _badPinWarning = qsTrId("settings_devicelock-la-incorrect_lock_code")
                clear()
            }
        }
    }
}
