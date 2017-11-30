import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

PinInput {
    id: input

    property bool requestSignalOnly: true

    //% "Use device security code"
    readonly property string useDeviceLockCode: qsTrId("settings_devicelock-la-use_security_code")

    property AuthenticationInput authenticationInput

    showOkButton: authenticationInput && authenticationInput.status === AuthenticationInput.Authenticating

    minimumLength: authenticationInput ? authenticationInput.minimumCodeLength : 0
    maximumLength: authenticationInput ? authenticationInput.maximumCodeLength : 64
    showDigitPad: authenticationInput && !authenticationInput.codeInputIsKeyboard
    suggestionsEnforced: authenticationInput && authenticationInput.codeGeneration === AuthenticationInput.MandatoryCodeGeneration

    warningTextColor: {
        if (emergency) {
            return Theme.primaryColor
        } else if (inputEnabled) {
            return Theme.highlightColor
        } else {
            return Theme.secondaryHighlightColor
        }
    }

    //: Devicelock UI's header-text which indicates Locked state.
    //% "Enter current security code"
    titleText: qsTrId("settings_devicelock-he-enter_current_security_code")

    //: Devicelock UI's enter-key which is pressed to confirm the new lockingComboboxlockcode.
    //% "Enter"
    okText: (enteringNewPin || requestSignalOnly) ? qsTrId("settings_devicelock-bt-enter")
                             //: Devicelock UI's unlock-key which is pressed to confirm the lockcode.
                             //% "Unlock"
                           : qsTrId("settings_devicelock-bt-unlock")

    //% "Security code cannot be more than %n digits."
    pinLengthWarning: qsTrId("settings_devicelock-la-devicelock_max_length_warning", maximumLength)

    //% "You need at least %n digits."
    pinShortLengthWarning: qsTrId("settings_devicelock-la-devicelock_min_length_warning", minimumLength)

    //: Enter a new security code
    //% "Enter new security code"
    enterNewPinText: qsTrId("settings_devicelock-he-enter_new_security_code")

    //: Re-enter the security code that was just entered
    //% "Re-enter new security code"
    confirmNewPinText: qsTrId("settings_devicelock-he-reenter_new_security_code")

    //: Shown when a new security code is entered twice for confirmation but the two entered lock codes are not the same.
    //% "Re-entered security code did not match."
    pinMismatchText: qsTrId("settings_devicelock-he-reentered_security_code_mismatch")

    //: Shown when the new PIN is not allowed because it is the same as the current PIN.
    //% "The new security code cannot be the same as the current security code."
    pinUnchangedText: qsTrId("settings_pin-he-new_security_code_same_as_old")

    onPinConfirmed: authenticationInput.enterSecurityCode(enteredPin)

    onPinEntryCanceled: {
        clear()
        authenticationInput.cancel()
    }

    onSuggestionRequested: authenticationInput.requestSecurityCode()

    function displayFeedback(feedback, data) {
        var attemptsRemaining = data.attemptsRemaining !== undefined ? data.attemptsRemaining : -1

        switch (feedback) {
        case AuthenticationInput.EnterSecurityCode:
            clear()
            _overridingTitleText = titleText
            break
        case AuthenticationInput.EnterNewSecurityCode:
            clear()
            _overridingTitleText = enterNewPinText
            suggestionsEnabled = authenticationInput.codeGeneration === AuthenticationInput.OptionalCodeGeneration
            if (data.securityCode) {
                suggestionsEnabled = true
                suggestPin(data.securityCode)
            }
            break
        case AuthenticationInput.RepeatNewSecurityCode:
            _badPinWarning = ""
            clear()
            _overridingTitleText = confirmNewPinText
            break
        case AuthenticationInput.SuggestSecurityCode:
            clear()
            _overridingTitleText = enterNewPinText
            suggestPin(data.securityCode)
            break
        case AuthenticationInput.SecurityCodesDoNotMatch:
            _badPinWarning = pinMismatchText
            break
        case AuthenticationInput.SecurityCodeInHistory:
            _badPinWarning = pinUnchangedText
            break
        case AuthenticationInput.SecurityCodeExpired:
            //% "The security code has expired and must be changed."
            _badPinWarning = qsTrId("settings_pin-he-security-code-expired")
            break
        case AuthenticationInput.PartialPrint:
            //% "Adjust your grip"
            _overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_partial_print")
            break
        case AuthenticationInput.PrintIsUnclear:
            //% "Press firmer"
            _overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_print_unclear")
            break
        case AuthenticationInput.SensorIsDirty:
            //% "Clean the sensor"
            _overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_sensor_is_dirty")
            break
        case AuthenticationInput.SwipeFaster:
            //% "Swipe faster"
            _overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_faster")
            break
        case AuthenticationInput.SwipeSlower:
            //% "Swipe slower"
            _overridingWarningText = qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_slower")
            break
        case AuthenticationInput.UnrecognizedFinger:
            if (attemptsRemaining == 0) {
                //% "Unrecognized finger. Enter your pin"
                _overridingWarningText = qsTrId("settings_devicelock-la-devicelock_unrecognized_finger_enter_pin")
            } else {
                //% "Unrecognized finger"
                _overridingWarningText = qsTrId("settings_devicelock-la-devicelock_unrecognized_finger")
            }

            break
        case AuthenticationInput.IncorrectSecurityCode:
            clear()
            if (attemptsRemaining == 0) {
                // Do nothing, this will be followed by a locked out error.
            } else if (attemptsRemaining == 1) {
                //% "Final chance"
                _overridingTitleText = qsTrId("lipstick-jolla-home-he-devicelock_final_chance")
                lastChance = true
                //% "Entering incorrent security code once more will permanently block your access to the device."
                _overridingWarningText = qsTrId("lipstick-jolla-home-la-devicelock_last_chance")
            } else {
                var counterText = attemptsRemaining > 0
                        ? " ("
                            + (authenticationInput.maximumAttempts - attemptsRemaining)
                            + "/"
                            + authenticationInput.maximumAttempts
                            + ")"
                        : ""
                //% "Incorrect security code"
                _overridingWarningText = qsTrId("settings_devicelock-la-incorrect_security_code") + counterText
            }
            break
        case AuthenticationInput.ContactSupport:
            //% "Please contact your IT support"
            _overridingWarningText = qsTrId("settings_devicelock-la-contact_support")
            break
        case AuthenticationInput.TemporarilyLocked:
            //% "The device has been temporarily locked, try again later"
            _overridingWarningText = qsTrId("settings_devicelock-la-temporarily_locked")
            break
        case AuthenticationInput.PermanentlyLocked:
            //% "The device has been permanently locked"
            _overridingWarningText = qsTrId("settings_devicelock-la-permanently_locked")
            break
        case AuthenticationInput.UnlockToPerformOperation:
            //% "The device is locked and must be unlocked to continue"
            _overridingWarningText = qsTrId("settings_devicelock-la-unlock_to_perform_operation")
            break
        }
    }

    function displayError(error) {
        clear()
        inputEnabled = false
        switch (error) {
        case AuthenticationInput.FunctionUnavailable:
            //% "Unavailable"
            input._overridingTitleText = qsTrId("settings_devicelock-la-devicelock_unavailable")
            //% "Device is locked"
            input._overridingWarningText = qsTrId("settings_devicelock-la-devicelock_device_is_locked")
            break
        case AuthenticationInput.LockedByManager:
            //% "Locked by Sailfish Device Manager"
            input._overridingTitleText = qsTrId("settings_devicelock-la-devicelock_locked_by_manager")
            input._overridingWarningText = ""
            break
        case AuthenticationInput.MaximumAttemptsExceeded:
            //% "Too many attempts"
            input._overridingTitleText = qsTrId("settings_devicelock-la-devicelock_maximum_attempts_exceeded")
            input._overridingWarningText = ""
            break
        case AuthenticationInput.Canceled:
            break
        case AuthenticationInput.SoftwareError:
            //% "Authentication unavailable"
            input._overridingTitleText = qsTrId("settings_devicelock-la-devicelock_software_error")
            input._overridingWarningText = ""
            break
        }
    }

    Connections {
        target: input.authenticationInput

        onFeedback: input.displayFeedback(feedback, data)
        onError: input.displayError(error)
    }
}
