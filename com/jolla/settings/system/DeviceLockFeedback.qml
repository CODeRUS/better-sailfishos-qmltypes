import QtQuick 2.6
import Sailfish.Silica 1.0
import org.nemomobile.devicelock 1.0

Connections {
    property AuthenticationInput agent
    property QtObject ui
    property bool submitted

    //% "Confirm with security code"
    property string acceptTitle: qsTrId("settings_devicelock-he-security_code_confirm_title")

    //% "Confirm"
    property string confirmText: qsTrId("settings_devicelock-bt-devicelock_confirm")

    //: Devicelock UI's enter-key which is pressed to confirm the new security code.
    //% "Enter"
    property string enterText: qsTrId("settings_devicelock-bt-enter")

    target: agent
    ignoreUnknownSignals: true

    function warn(message, isTransient) {
        ui.transientWarningText = message
        if (!isTransient) {
            ui.warningText = message
        }
    }

    onReset: {
        submitted = false
        ui.titleColor = Qt.binding(function() { return Theme.highlightColor })
        ui.inputEnabled = true
        ui.suggestionsEnabled = false
        ui.requireSecurityCode = true
        ui.warningText = ""
        ui.transientWarningText = ""
        ui.securityCode = ""
    }

    onFeedback: {
        if (submitted) {
            submitted = false
            ui.warningText = ""
            ui.securityCode = ""
            ui.transientWarningText = ""
        }

        var attemptsRemaining = data.attemptsRemaining !== undefined ? data.attemptsRemaining : -1

        switch (feedback) {
        case AuthenticationInput.Authorize:
            //% "Authorize"
            ui.titleText = qsTrId("settings_devicelock-he-authorize")
            ui.okText = confirmText
            ui.descriptionText = data.message || ""
            ui.suggestionsEnabled = false
            ui.requireSecurityCode = false
            break
        case AuthenticationInput.EnterSecurityCode:
            ui.titleText = acceptTitle
            ui.okText = confirmText
            ui.descriptionText = data.message || ""
            ui.suggestionsEnabled = false
            ui.requireSecurityCode = true
            ui.focusIn()
            break
        case AuthenticationInput.EnterNewSecurityCode:
        case AuthenticationInput.SuggestSecurityCode:
            //: Enter a new security code
            //% "Enter new security code"
            ui.titleText = qsTrId("settings_devicelock-he-enter_new_security_code")
            ui.descriptionText = data.message || ""
            ui.okText = enterText
            ui.suggestionsEnabled = agent.codeGeneration === AuthenticationInput.OptionalCodeGeneration
            ui.requireSecurityCode = true
            if (data.securityCode) {
                ui.suggestionsEnabled = true
                ui.suggestSecurityCode(data.securityCode)
            } else {
                ui.focusIn()
            }
            break
        case AuthenticationInput.RepeatNewSecurityCode:
            //: Re-enter the security code that was just entered
            //% "Re-enter new security code"
            ui.titleText = qsTrId("settings_devicelock-he-reenter_new_security_code")
            ui.descriptionText = data.message || ""
            ui.okText = enterText
            break
        case AuthenticationInput.SecurityCodesDoNotMatch:
            //: Shown when a new security code is entered twice for confirmation but the two entered lock codes are not the same.
            //% "Re-entered security code did not match."
            warn(data.warning || qsTrId("settings_devicelock-he-reentered_security_code_mismatch"), !data.persistWarning)
            break
        case AuthenticationInput.SecurityCodeInHistory:
            //: Shown when the new security code is not allowed because it is the same as the current security code.
            //% "The new security code cannot be the same as the current security code."
            warn(data.warning || qsTrId("settings_devicelock-he-new_security_code_same_as_old"), !data.persistWarning)
            break
        case AuthenticationInput.SecurityCodeExpired:
            //% "The security code has expired and must be changed."
            warn(data.warning || qsTrId("settings_devicelock-he-security-code-expired"), !data.persistWarning)
            break
        case AuthenticationInput.PartialPrint:
            //% "Adjust your grip"
            warn(data.warning || qsTrId("settings_devicelock-la-fingerprint_feedback_partial_print"), !data.persistWarning)
            break
        case AuthenticationInput.PrintIsUnclear:
            //% "Press firmer"
            warn(data.warning || qsTrId("settings_devicelock-la-fingerprint_feedback_print_unclear"), !data.persistWarning)
            break
        case AuthenticationInput.SensorIsDirty:
            //% "Clean the sensor"
            warn(data.warning || qsTrId("settings_devicelock-la-fingerprint_feedback_sensor_is_dirty"), !data.persistWarning)
            break
        case AuthenticationInput.SwipeFaster:
            //% "Swipe faster"
            warn(data.warning || qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_faster"), !data.persistWarning)
            break
        case AuthenticationInput.SwipeSlower:
            //% "Swipe slower"
            warn(data.warning || qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_slower"), !data.persistWarning)
            break
        case AuthenticationInput.UnrecognizedFinger:
            warn(data.message || (attemptsRemaining === 0
                    //% "Unrecognized finger. Enter your security code"
                    ? qsTrId("settings_devicelock-la-devicelock_unrecognized_finger_enter_security_code")
                    //% "Unrecognized finger"
                    : qsTrId("settings_devicelock-la-devicelock_unrecognized_finger")), !data.persistWarning)
            break
        case AuthenticationInput.IncorrectSecurityCode:
            if (attemptsRemaining === 0) {
                // Do nothing, this will be followed by a locked out error.
            } else if (attemptsRemaining === 1) {
                ui.titleColor = "#ff4956"
                //% "Final chance"
                ui.titleText = qsTrId("settings_devicelock-he-devicelock_final_chance")
                //% "Entering an incorrect security code once more will permanently block your access to the device."
                warn(data.warning || qsTrId("settings_devicelock-la-devicelock_last_chance"), false)
            } else {
                var counterText = attemptsRemaining > 0
                        ? " (" + (agent.maximumAttempts - attemptsRemaining) + "/" + agent.maximumAttempts + ")"
                        : ""
                //% "Incorrect security code"
                warn(data.warning || (qsTrId("settings_devicelock-la-incorrect_security_code") + counterText), !data.persistWarning)
            }
            break
        case AuthenticationInput.ContactSupport:
            //% "Please contact your IT support"
            warn(data.warning || qsTrId("settings_devicelock-la-contact_support"), false)
            break
        case AuthenticationInput.TemporarilyLocked:
            //% "The device has been temporarily locked, try again later"
            warn(data.warning ||  qsTrId("settings_devicelock-la-temporarily_locked"), false)
            ui.transientWarningText = ui.warningText
            break
        case AuthenticationInput.PermanentlyLocked:
            //% "The device has been permanently locked"
            warn(data.warning || qsTrId("settings_devicelock-la-permanently_locked"), false)
            break
        case AuthenticationInput.UnlockToPerformOperation:
            //% "The device is locked and must be unlocked to continue"
            warn(data.warning || qsTrId("settings_devicelock-la-unlock_to_perform_operation"), false)
            break
        }
    }

    onError: {
        ui.inputEnabled = false
        ui.securityCode = ""
        ui.transientWarningText = ""
        switch (error) {
        case AuthenticationInput.FunctionUnavailable:
            //% "Unavailable"
            ui.titleText = qsTrId("settings_devicelock-la-devicelock_unavailable")
            ui.descriptionText = data.message || ""
            //% "Device is locked"
            warn(data.warning || qsTrId("settings_devicelock-la-devicelock_device_is_locked"), false)
            break
        case AuthenticationInput.LockedByManager:
            //% "Locked by Sailfish Device Manager"
            ui.titleText = qsTrId("settings_devicelock-la-devicelock_locked_by_manager")
            ui.descriptionText = data.message || ""
            warn(data.warning || "", false)
            break
        case AuthenticationInput.MaximumAttemptsExceeded:
            //% "Too many attempts"
            ui.titleText = qsTrId("settings_devicelock-la-devicelock_maximum_attempts_exceeded")
            ui.descriptionText = data.message || ""
            warn(data.warning || "", false)
            ui.transientWarningText = ui.warningText
            break
        case AuthenticationInput.Canceled:
            break
        case AuthenticationInput.SoftwareError:
            //% "Authentication unavailable"
            ui.titleText = qsTrId("settings_devicelock-la-devicelock_software_error")
            ui.descriptionText = data.message || ""
            warn(data.warning || "", false)
            break
        }
    }
}
