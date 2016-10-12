import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

PinInput {
    id: input

    property bool requestSignalOnly: true

    //% "Use device lock code"
    readonly property string useDeviceLockCode: qsTrId("settings_devicelock-la-use_lock_code")

    property Authenticator authenticator

    minimumLength: authenticator ? authenticator.minimumCodeLength : 0
    maximumLength: authenticator ? authenticator.maximumCodeLength : 64
    showDigitPad: !authenticator || !authenticator.codeInputIsKeyboard


    //: Devicelock UI's header-text which indicates Locked state.
    //% "Enter current lock code"
    titleText: qsTrId("settings_devicelock-he-enter_current_lock_code")

    //: Devicelock UI's enter-key which is pressed to confirm the new lockingComboboxlockcode.
    //% "Enter"
    okText: (enteringNewPin || requestSignalOnly) ? qsTrId("settings_devicelock-bt-enter")
                             //: Devicelock UI's unlock-key which is pressed to confirm the lockcode.
                             //% "Unlock"
                           : qsTrId("settings_devicelock-bt-unlock")

    //% "Lock code cannot be more than %n digits."
    pinLengthWarning: qsTrId("settings_devicelock-la-devicelock_max_length_warning", maximumLength)

    //% "You need atleast %n digits."
    pinShortLengthWarning: qsTrId("settings_devicelock-la-devicelock_min_length_warning", minimumLength)

    //: Enter a new lock code
    //% "Enter new lock code"
    enterNewPinText: qsTrId("settings_devicelock-he-enter_new_lock_code")

    //: Re-enter the lock code that was just entered
    //% "Re-enter new lock code"
    confirmNewPinText: qsTrId("settings_devicelock-he-reenter_new_lock_code")

    //: Shown when a new lock code is entered twice for confirmation but the two entered lock codes are not the same.
    //% "Re-entered lock code did not match."
    pinMismatchText: qsTrId("settings_devicelock-he-reentered_lock_code_mismatch")

    //: Shown when the new PIN is not allowed because it is the same as the current PIN.
    //% "The new lock code cannot be the same as the current lock code."
    pinUnchangedText: qsTrId("settings_pin-he-new_lock_code_same_as_old")

    Connections {
        target: input.authenticator

        onFeedback: {
            switch (feedback) {
            case Authenticator.PartialPrint:
                //% "Adjust your grip"
                input._overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_partial_print")
                break
            case Authenticator.PrintIsUnclear:
                //% "Press firmer"
                input._overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_print_unclear")
                break
            case Authenticator.SensorIsDirty:
                //% "Clean the sensor"
                input._overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_sensor_is_dirty")
                break
            case Authenticator.SwipeFaster:
                //% "Swipe faster"
                input._overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_faster")
                break
            case Authenticator.SwipeSlower:
                //% "Swipe slower"
                input._overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_slower")
                break
            case Authenticator.UnrecognizedFinger:
                if (attemptsRemaining == 0) {
                    //% "Unrecognized finger.  Enter your pin"
                    input._overridingWarningText = qsTrId("settings_devicelock-la-devicelock_unrecognized_finger_enter_pin")
                } else {
                    //% "Unrecognized finger"
                    input._overridingWarningText = qsTrId("settings_devicelock-la-devicelock_unrecognized_finger")
                }

                break
            case Authenticator.IncorrectLockCode:
                input.clear()
                if (attemptsRemaining == 0) {
                    // Do nothing, this will be followed by a locked out error.
                } else if (attemptsRemaining == 1) {
                    //% "Final chance"
                    input.titleText = qsTrId("lipstick-jolla-home-he-devicelock_final_chance")
                    input.lastChance = true
                    //% "Entering incorrent lock code once more will permanently block your access to the device."
                    input._overridingWarningText = qsTrId("lipstick-jolla-home-la-devicelock_last_chance")
                } else {
                    var counterText = attemptsRemaining > 0
                            ? " ("
                                + (input.authenticator.maximumAttempts - attemptsRemaining)
                                + "/"
                                + input.authenticator.maximumAttempts
                                + ")"
                            : ""
                    //% "Incorrect lock code"
                    input._overridingWarningText = qsTrId("settings_devicelock-la-incorrect_lock_code") + counterText
                }
                break
            }
        }

        onError: {
            switch (error) {
            case Authenticator.LockedOut:
                //% "Permanently Locked"
                input.titleText = qsTrId("settings_devicelock-la-devicelock_permanently_locked")
                input.showOkButton = false
                input._overridingWarningText = ""
            }
        }
    }
}
