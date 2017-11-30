import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.QOfono 0.2
import org.nemomobile.lipstick 0.1
import org.nemomobile.ofono 1.0

Item {
    id: root

    // read-only
    property string enteredPin
    property bool emergency
    property bool enteringNewPin

    property bool showCancelButton: true
    property bool showOkButton: true
    property int minimumLength: 4
    property int maximumLength

    // modem for emergency calls
    property string modemPath: modemManager.defaultVoiceModem || manager.defaultModem

    //: Confirms the entered PIN
    //% "Enter"
    property string okText: qsTrId("settings_pin-bt-enter_pin")

    //: Cancels PIN entry
    //% "Cancel"
    property string cancelText: qsTrId("settings_pin-bt-cancel_pin")

    property string titleText
    property color titleColor: Theme.secondaryHighlightColor
    property string subTitleText
    property string warningText
    property color warningTextColor: _inputOrCancelEnabled ? Theme.primaryColor : Theme.secondaryHighlightColor
    property bool highlightTitle: !_inputOrCancelEnabled && !emergency
    property color pinDisplayColor: Theme.highlightColor
    property color keypadTextColor: Theme.primaryColor
    property bool dimmerBackspace
    property color emergencyTextColor: "red"

    property string _passwordCharacter: "\u2022"
    property string _displayedPin
    property string _oldPin
    property string _newPin

    property real headingVerticalOffset

    property string _pinConfirmTitleText
    property string _badPinWarning
    property string _overridingTitleText
    property string _overridingWarningText
    property string _emergencyWarningText
    property bool lastChance

    property bool _showSuggestedPin
    property bool suggestionsEnabled
    property bool suggestionsEnforced
    readonly property bool _showSuggestionButton: !emergency
            && ((_showSuggestedPin && suggestionsEnforced) || (suggestionsEnabled && enteredPin === ""))

    property bool showEmergencyButton: true

    //: Warns that the entered PIN was too long.
    //% "PIN cannot be more than %n digits."
    property string pinLengthWarning: qsTrId("settings_pin-la-pin_max_length_warning", maximumLength)
    property string pinShortLengthWarning
    //: Enter a new PIN code
    //% "Enter new PIN"
    property string enterNewPinText: qsTrId("settings_pin-he-enter_new_pin")
    //: Re-enter the PIN code that was just entered
    //% "Re-enter new PIN"
    property string confirmNewPinText: qsTrId("settings_pin-he-reenter_new_pin")
    //: Shown when a new PIN is entered twice for confirmation but the two entered PINs are not the same.
    //% "Re-entered PIN did not match."
    property string pinMismatchText: qsTrId("settings_pin-he-reentered_pin_mismatch")
    //: Shown when the new PIN is not allowed because it is the same as the current PIN.
    //% "The new PIN cannot be the same as the current PIN."
    property string pinUnchangedText: qsTrId("settings_pin-he-new_pin_same_as_old")

    property QtObject _feedbackEffect
    property QtObject _voiceCallManager

    property bool showDigitPad: true
    property bool inputEnabled: true
    property bool _showDigitPad: (showDigitPad && _inputOrCancelEnabled)
            || emergency
            || (root._showSuggestedPin && root.suggestionsEnforced)
    property bool visibleInDashboard

    readonly property bool _inputOrCancelEnabled: inputEnabled || (showCancelButton && cancelText !== "")

    signal pinConfirmed()
    signal pinEntryCanceled()
    signal suggestionRequested()

    function clear() {
        inputEnabled = true
        lastChance = false
        suggestionsEnabled = false
        _showSuggestedPin = false
        _displayedPin = ""
        enteredPin = ""

        // Change status messages here and not when confirm button is clicked, else they may update
        // while the page is undergoing a pop transition when the PIN is confirmed.
        _overridingTitleText = _pinConfirmTitleText
        _overridingWarningText = _badPinWarning
        if (enteringNewPin && _pinConfirmTitleText === "") {
            enteringNewPin = false
        }
    }

    function suggestPin(pin) {
        _showSuggestedPin = true
        enteredPin = pin
        _displayedPin = pin
    }

    function clearSuggestedPin() {
        _showSuggestedPin = false
        enteredPin = ""
        _displayedPin = ""
    }

    // Delays emission of pinConfirmed() until the same PIN has been entered twice.
    // Also changes the title text to 'Enter new PIN' and 'Re-enter new PIN' as necessary.
    // If 'oldPin' is provided, the user is not allowed to enter this value as the new PIN.
    function requestAndConfirmNewPin(oldPin) {
        _oldPin = oldPin || ""
        _pinConfirmTitleText = enterNewPinText
        enteringNewPin = true
        clear()
    }

    function _clickedConfirmButton() {
        if (enteringNewPin) {
            if (_newPin === "") {
                _pinConfirmTitleText = confirmNewPinText
                _badPinWarning = ""
                _newPin = enteredPin
                clear()
            } else {
                if (enteredPin === _newPin) {
                    pinConfirmed()
                    _newPin = ""
                    _badPinWarning = ""
                    _pinConfirmTitleText = ""
                } else {
                    _badPinWarning = pinMismatchText
                    _pinConfirmTitleText = confirmNewPinText
                    _newPin = ""
                    clear()
                }
            }
        } else {
            pinConfirmed()
        }
    }

    function _pushPinDigit(digit) {
        if (emergency) {
            obfuscateLastDigit.stop()
            if (enteredPin.length > 100) {
                return
            }
            _displayedPin += digit
            enteredPin += digit
        } else {
            if (_showSuggestedPin) {
                clearSuggestedPin()
            }

            if (maximumLength > 0 && enteredPin.length >= maximumLength) {
                _overridingWarningText = pinLengthWarning
                return
            }
            obfuscateLastDigit.stop()
            _displayedPin = _passwordString(_displayedPin.length) + digit
            enteredPin += digit
            obfuscateLastDigit.start()
            if (minimumLength > enteredPin.length) {
                _overridingWarningText = pinShortLengthWarning
            } else if (minimumLength === enteredPin.length) {
                _overridingWarningText = ""
            }
            _checkEnteredPin()
        }
    }

    function _popPinDigit(digit) {
        if (_feedbackEffect) {
            _feedbackEffect.play()
        }
        if (_showSuggestedPin) {
            clearSuggestedPin()
            return
        }
        obfuscateLastDigit.stop()
        if (_overridingWarningText === pinLengthWarning) {
            _overridingWarningText = ""
        }
        _displayedPin = _displayedPin.slice(0, _displayedPin.length-1)
        enteredPin = enteredPin.slice(0, enteredPin.length-1)
        if (enteredPin.length === 0) {
            _overridingWarningText = ""
        } else if (minimumLength > enteredPin.length) {
            _overridingWarningText = pinShortLengthWarning
        }
        _checkEnteredPin()
    }

    function _changedPinValid() {
        if (!enteringNewPin || _oldPin == "") {
            return true
        }
        return _oldPin != enteredPin
    }

    function _checkEnteredPin() {
        if (_changedPinValid()) {
            _overridingWarningText = ""
        } else {
            _overridingWarningText = pinUnchangedText
        }
    }

    function _passwordString(len) {
        var s = ""
        for (var i=0; i<len; i++) {
            s = s + _passwordCharacter
        }
        return s
    }

    width: parent.width
    height: parent.height

    onEmergencyChanged: {
        if (!emergency) {
            _emergencyWarningText = ""
        } else if (_showSuggestedPin) {
            clearSuggestedPin()
        }
    }

    Rectangle {
        // emergency background
        color: "#4c0000"
        anchors.fill: parent
        opacity: root.emergency ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }

    Timer {
        id: obfuscateLastDigit
        interval: 1000
        onTriggered: {
            if (!root.emergency && !root._showSuggestedPin) {
                _displayedPin = _passwordString(_displayedPin.length)
            }
        }
    }

    Image {
        anchors {
            horizontalCenter: root.horizontalCenter
            bottom: headingColumn.top
            bottomMargin: Theme.paddingLarge
        }
        visible: !root._inputOrCancelEnabled && !root.emergency

        source: "image://theme/icon-m-device-lock?" + headingLabel.color
    }

    Column {
        id: headingColumn

        property int availableSpace: pinInputDisplay.y

        y: root._inputOrCancelEnabled || root.emergency
                ? Math.min(availableSpace/4 + headingVerticalOffset, availableSpace - height - Theme.paddingMedium)
                : (parent.height / 2) - headingLabel.height - subHeadingLabel.height
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - Theme.horizontalPageMargin * 2
        spacing: Theme.paddingMedium

        Label {
            id: headingLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: root.emergency
                   ? root.emergencyTextColor
                   :  root.lastChance
                     ? "#ff4956"
                     : root.highlightTitle
                       ? Theme.secondaryHighlightColor
                       : root.titleColor
            font.pixelSize: Theme.fontSizeExtraLarge
            text: root.emergency
                      //: Shown when user has chosen emergency call mode
                      //% "Emergency call"
                    ? qsTrId("settings_pin-la-emergency_call")
                    : (root._overridingTitleText !== "" ? root._overridingTitleText : root.titleText)
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: headingLabel.color
            visible: root._inputOrCancelEnabled || root.emergency
            font.pixelSize: Theme.fontSizeExtraLarge
            text: root.subTitleText
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: root.warningTextColor

            font.pixelSize: root._inputOrCancelEnabled ? Theme.fontSizeSmall : Theme.fontSizeMedium
            text: {
                if (root.emergency) {
                    return root._emergencyWarningText
                } else if (root._overridingWarningText !== "") {
                    return root._overridingWarningText
                } else {
                    return root.warningText
                }
            }
        }
    }

    BackgroundItem {
        anchors.centerIn: emergencyButton
        width: emergencyButton.width
        height: width
        down: emergencyButton.down
        visible: down
    }

    IconButton {
        id: emergencyButton

        anchors {
            horizontalCenter: root._inputOrCancelEnabled
                    ? option1Button.horizontalCenter
                    : root.horizontalCenter
            verticalCenter: root._inputOrCancelEnabled
                    ? pinInputDisplay.verticalCenter
                    : keypad.bottom
            verticalCenterOffset: {
                if (root._inputOrCancelEnabled) {
                    return 0
                } else if (Screen.sizeCategory > Screen.Medium) {
                    return -Math.round(Theme.itemSizeExtraLarge / 2)
                } else {
                    return -Math.round(Theme.itemSizeLarge / 2)
                }
            }
        }
        enabled: showEmergencyButton && !root.emergency && root.enteredPin.length < 5
        opacity: enabled ? 1 : 0
        icon.source: "image://theme/icon-lockscreen-emergency-call"

        Behavior on opacity { FadeAnimation {} }

        onClicked: {
            root._displayedPin = ""
            root.enteredPin = ""
            root.emergency = !root.emergency
            if (_feedbackEffect) {
                _feedbackEffect.play()
            }
        }
    }
    IconButton {
        x: Theme.itemSizeSmall
        anchors.verticalCenter: pinInputDisplay.verticalCenter
        height: pinInputDisplay.height + pinInputDisplay.anchors.bottomMargin
        enabled: !showEmergencyButton && !_showDigitPad && root.enteredPin.length < 5
        opacity: enabled ? 1 : 0
        icon.source: "image://theme/icon-m-close"

        Behavior on opacity { FadeAnimation {} }

        onClicked: {
            if (_feedbackEffect) {
                _feedbackEffect.play()
            }
            root.pinEntryCanceled()
        }
    }

    Label {
        id: pinInputDisplay
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: backspace.left
            rightMargin: Theme.paddingSmall
            bottom: showEmergencyButton || keypad.visible ? keypad.top : alphanumProxy.bottom
            bottomMargin: Theme.itemSizeSmall / 2
        }
        horizontalAlignment: Text.AlignRight
        truncationMode: TruncationMode.Fade

        color: root.emergency ? "white" : root.pinDisplayColor
        font.pixelSize: Theme.fontSizeHuge * 1.5
        text: root._displayedPin
    }

    IconButton {
        id: backspace
        anchors {
            horizontalCenter: option2Button.horizontalCenter
            verticalCenter: pinInputDisplay.verticalCenter
        }
        height: pinInputDisplay.height + pinInputDisplay.anchors.bottomMargin // increase reactive area
        icon.source: root._showSuggestionButton
                ? "image://theme/icon-m-reload"
                : ("image://theme/icon-m-backspace" + (root.dimmerBackspace && !root.emergency
                    ? "?" + Theme.highlightDimmerColor
                    : ""))

        opacity: root.enteredPin === "" && !root._showSuggestionButton ? 0 : 1
        enabled: opacity

        Behavior on opacity { FadeAnimation {} }

        onClicked: {
            if (root._showSuggestionButton) {
                 root.suggestionRequested()
            } else {
                root._popPinDigit()
            }
        }
        onPressAndHold: {
            if (root._showSuggestionButton) {
                return
            }
            root._popPinDigit()
            if (root._displayedPin.length > 0) {
                backspaceRepeat.start()
            }
        }
        onExited: {
            backspaceRepeat.stop()
        }
        onReleased: {
            backspaceRepeat.stop()
        }
        onCanceled: {
            backspaceRepeat.stop()
        }
    }

    Timer {
        id: backspaceRepeat

        interval: 150
        repeat: true

        onTriggered: {
            root._popPinDigit()
            if (root._displayedPin.length === 0) {
                stop()
            }
        }
    }

    Keypad {
        id: keypad
        readonly property bool interactive: root.emergency
                    || (root.inputEnabled && !(root._showSuggestedPin && root.suggestionsEnforced))
        anchors {
            bottom: parent.bottom
            bottomMargin: screen.sizeCategory > Screen.Medium && pageStack.currentPage.isPortrait ? 2*Theme.paddingLarge
                                                                                                  : Theme.paddingLarge
        }
        symbolsVisible: false
        visible: opacity > 0
        opacity: _showDigitPad
        textColor: {
            if (root.emergency) {
                return root.emergencyTextColor
            } else if (interactive) {
                return root.keypadTextColor
            } else {
                return Theme.highlightColor
            }
        }

        pressedTextColor: root.emergency ? "black" : Theme.highlightColor
        pressedButtonColor: root.emergency
                            ? "white"
                            : Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        enabled: interactive
        onPressed: root._pushPinDigit(number + "")
    }

    PinInputOptionButton {
        id: option1Button
        visible: keypad.visible && text !== "" && showCancelButton

        anchors {
            left: parent.left
            leftMargin: keypad._horizontalPadding
            bottom: keypad.bottom
            bottomMargin: (keypad._buttonHeight - height) / 2
        }
        width: keypad._buttonWidth
        height: width / 2
        emergency: root.emergency
        text: root.emergency
              ? //: Cancels out of the emergency call mode and returns to the PIN input screen
                //% "Cancel"
                qsTrId("settings_pin-bt-cancel_emergency_call")
              : root.cancelText

        onClicked: {
            if (_feedbackEffect) {
                _feedbackEffect.play()
            }
            if (root.emergency) {
                root._resetView()
            } else {
                root.pinEntryCanceled()
            }
        }
    }

    PinInputOptionButton {
        id: option2Button

        visible: keypad.visible && text !== "" && ((root.showOkButton && root.inputEnabled) || root.emergency)

        anchors {
            right: parent.right
            rightMargin: keypad._horizontalPadding
            bottom: option1Button.bottom
        }
        width: option1Button.width
        height: option1Button.height
        emergency: root.emergency
        text: root.emergency
        //: Starts the phone call
        //% "Call"
              ? qsTrId("settings_pin-bt-start_call")
              : (root.enteredPin.length < minimumLength || !root._changedPinValid() ? "" : root.okText)
        showWhiteBackgroundByDefault: root.emergency

        onClicked: {
            if (_feedbackEffect) {
                _feedbackEffect.play()
            }
            if (root.emergency) {
                root._dialEmergencyNumber()
            } else {
                root._clickedConfirmButton()
            }
        }
    }

    TextInput {
        id: alphanumProxy
        width: parent.width
        visible: !keypad.visible
        y: Qt.inputMethod.keyboardRectangle.y - Theme.itemSizeSmall

        horizontalAlignment: TextInput.AlignHCenter
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhHiddenText
        enabled: root.inputEnabled && !(root._showSuggestedPin && root.suggestionsEnforced)
        focus: !keypad.visible
        color: root.keypadTextColor
        onCursorVisibleChanged: if (cursorVisible) cursorVisible = false
        font.pixelSize: Theme.fontSizeSmall
        onFocusChanged: {
            if (!focus && !_showDigitPad) {
                root.pinEntryCanceled()
                if (showEmergencyButton && visibleInDashboard) {
                    alphanumProxy.forceActiveFocus()
                }
            }
        }
        onTextChanged: {
            if (text.length) root._pushPinDigit(text + "")
            text = ""
        }
        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace) root._popPinDigit()
            else if (event.key == Qt.Key_Enter) root._clickedConfirmButton()
            else if (event.key == Qt.Key_Return) root._clickedConfirmButton()
        }
        EnterKey.enabled: root.enteredPin.length >= minimumLength
        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
    }

    OfonoModemManager { id: modemManager }
    OfonoManager { id: manager }

    OfonoModem {
        id: modem
        modemPath: root.modemPath
    }

    OfonoVoiceCallManager {
        id: voiceCallManager
        modemPath: root.modemPath
    }

    // To make an emergency call: (as per ofono emergency-call-handling.txt)
    // 1) Set org.ofono.Modem online=true
    // 2) Dial number using telephony VoiceCallManager
    function _dialEmergencyNumber() {
        root._emergencyWarningText = ""
        if (!modem.online) {
            modem.onlineChanged.connect(_dialEmergencyNumber)
            modem.online = true
            return
        }
        modem.onlineChanged.disconnect(_dialEmergencyNumber)
        var emergencyNumbers = voiceCallManager.emergencyNumbers
        if (root.enteredPin !== "" && emergencyNumbers.indexOf(root.enteredPin) === -1) {
            //: Indicates that user has entered invalid emergency number
            //% "Only emergency calls permitted"
            root._emergencyWarningText = qsTrId("settings_pin-la-invalid_emergency_number")
            return
        }

        // If no number has been entered,
        // prefill emergency number with GSM standard "112"
        if (root.enteredPin === "") {
            var emergencyNumber = "112"
            for (var i=0; i<emergencyNumber.length; i++) {
                _pushPinDigit(emergencyNumber[i])
            }
        }
        if (!_voiceCallManager) {
            _voiceCallManager = Qt.createQmlObject("import QtQuick 2.0; import org.nemomobile.voicecall 1.0; VoiceCallManager {}",
                               root, 'VoiceCallManager');
            _voiceCallManager.modemPath = Qt.binding(function() { return root.modemPath })
        }
        _voiceCallManager.dial(root.enteredPin)
    }

    function _resetView() {
        _displayedPin = ""
        enteredPin = ""
        emergency = false
    }

    // Reset view on Device lock & start up pinquery
    Connections {
        target: Lipstick.compositor
        onHomeActiveChanged: if (!Lipstick.compositor.homeActive) delayReset.start()
    }

    // Reset view on pinquery when viewed from settings/applications.
    Connections {
        target: Qt.application
        onActiveChanged: if (Qt.application.active) delayReset.start()
    }

    Timer {
        id: delayReset
        interval: 250
        onTriggered: root._resetView()
    }

    on_ShowDigitPadChanged: {
        if (!_showDigitPad && inputEnabled) {
            alphanumProxy.forceActiveFocus()
        }
    }

    onVisibleInDashboardChanged: {
        if (!_showDigitPad && visibleInDashboard && enabled && inputEnabled) {
            alphanumProxy.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        // Avoid hard dependency to feedback
        _feedbackEffect = Qt.createQmlObject("import QtQuick 2.0; import QtFeedback 5.0; ThemeEffect { effect: ThemeEffect.PressWeak }",
                           root, 'ThemeEffect');
    }
}
