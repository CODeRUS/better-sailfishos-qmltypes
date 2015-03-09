import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0

PinInput {
    DeviceLockSettings {
        id: lockSettings
    }
    showDigitPad: !lockSettings.codeInputIsKeyboard
    minimumLength: lockSettings.codeMinLength
    maximumLength: lockSettings.codeMaxLength
    //% "Lock code cannot be more than %n digits."
    pinLengthWarning: qsTrId("settings_devicelock-la-devicelock_max_length_warning", maximumLength)
}
