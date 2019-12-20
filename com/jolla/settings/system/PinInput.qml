import QtQuick 2.6
import Sailfish.Silica 1.0
import MeeGo.QOfono 0.2
import org.nemomobile.lipstick 0.1
import org.nemomobile.ofono 1.0

FocusScope {
    id: root

    // read-only
    property alias enteredPin: pinInput.text
    property bool emergency
    property bool enteringNewPin

    property bool showCancelButton: true
    property bool showOkButton: true
    property bool busy

    property int minimumLength: 4
    property int maximumLength

    // modem for emergency calls
    property string modemPath: modemManager.defaultVoiceModem || manager.defaultModem

    // okText and cancelText are no longer in use. See JB#46010 and JB#46275

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
    property string transientWarningText
    property color warningTextColor: _inputOrCancelEnabled ? Theme.primaryColor : Theme.secondaryHighlightColor
    property bool highlightTitle: !_inputOrCancelEnabled && !emergency
    property color pinDisplayColor: Theme.highlightColor
    property color keypadTextColor: Theme.primaryColor
    property bool dimmerBackspace
    property color emergencyTextColor: "red"

    property int inputMethodHints: showDigitPad ? Qt.ImhDigitsOnly : Qt.ImhNone
    property int echoMode: TextInput.Password
    property alias passwordMaskDelay: pinInput.passwordMaskDelay

    property alias _passwordCharacter: pinInput.passwordCharacter
    property alias _displayedPin: pinInput.displayText
    property string _oldPin
    property string _newPin

    property real headingVerticalOffset

    property string _pinConfirmTitleText
    property string _badPinWarning
    property string _overridingTitleText
    property string _emergencyWarningText
    property bool lastChance

    property bool suggestionsEnabled
    property bool suggestionsEnforced
    readonly property bool _showSuggestionButton: suggestionsEnabled
                && (suggestionsEnforced || pinInput.length === 0 || suggestionVisible)
    readonly property bool suggestionVisible: pinInput.length > 0
                && pinInput.selectionStart !== pinInput.selectionEnd

    property bool requirePin: true

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

    readonly property string _pinValidationWarningText: {
        if (enteredPin === "") {
            return ""
        } else if (enteringNewPin && _oldPin === enteredPin) {
            return pinUnchangedText
        } else if (_pinMismatch) {
            return pinMismatchText
        } else if (pinInput.length < minimumLength) {
            return pinShortLengthWarning
        } else if (maximumLength > 0 && pinInput.length > maximumLength) {
            return pinLengthWarning
        } else {
            return ""
        }
    }

    property QtObject _feedbackEffect
    property QtObject _voiceCallManager

    property bool showDigitPad: true
    property bool inputEnabled: true
    property bool _showDigitPad: pinInput.inputMethodHints & (Qt.ImhDigitsOnly | Qt.ImhDialableCharactersOnly)

    readonly property bool _pinMismatch: (enteringNewPin && pinInput.length >= minimumLength && _newPin !== "" && _newPin !== enteredPin)
    readonly property bool _inputOrCancelEnabled: inputEnabled || (showCancelButton && cancelText !== "")
    // Height rule an approximation without all margins exactly. Should cover currently used device set.
    readonly property bool _twoColumnMode: pageStack.currentPage.isLandscape && keypad.visible
                                           && height < (keypad.height + headingColumn.height + pinInput.height + Theme.itemSizeSmall)

    signal pinConfirmed()
    signal pinEntryCanceled()
    signal suggestionRequested()

    function clear() {
        inputEnabled = true
        lastChance = false
        suggestionsEnabled = false
        enteredPin = ""

        // Change status messages here and not when confirm button is clicked, else they may update
        // while the page is undergoing a pop transition when the PIN is confirmed.
        _overridingTitleText = _pinConfirmTitleText
        transientWarningText = _badPinWarning
        if (enteringNewPin && _pinConfirmTitleText === "") {
            enteringNewPin = false
        }
    }

    function suggestPin(pin) {
        enteredPin = pin
        pinInput.selectAll()
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

    function focusIn() {
        // Just ensure local focus.
        pinInput.focus = true
        focus = true
    }

    function _clickedConfirmButton() {
        if (enteringNewPin) {
            // extra protection for hw keyboard enter
            if (enteredPin.length < minimumLength)
                return

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

    function _popPinDigit() {
        if (suggestionVisible) {
            pinInput.remove(pinInput.selectionStart, pinInput.selectionEnd)
        } else {
            pinInput.remove(pinInput.length - 1, pinInput.length)
        }
    }

    function _handleNumberPress(number) {
        if (root.suggestionVisible && !root.emergency) {
            pinInput.remove(pinInput.selectionStart, pinInput.selectionEnd)
        }
        pinInput.cursorPosition = pinInput.length
        pinInput.insert(pinInput.cursorPosition, number)
    }

    function _handleCancelPress() {
        if (root.emergency) {
            root._resetView()
        } else {
            root.pinEntryCanceled()
        }
    }

    function _feedback() {
        if (_feedbackEffect) {
            _feedbackEffect.play()
        }
    }

    width: parent.width
    height: parent.height

    focus: true

    onEmergencyChanged: {
        if (!emergency) {
            _emergencyWarningText = ""
            pinInput.forceActiveFocus()
        }
    }

    onVisibleChanged: {
        if (!visible) {
            // Hiding the keyboard will remove focus from the pinInput.  Fixup the internal
            // state when the hidden so the keyboard comes back when shown again.
            pinInput.focus = true
        }
    }


    Rectangle {
        // emergency background
        color: "#4c0000"
        anchors.fill: parent
        opacity: root.emergency ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }

    Image {
        anchors {
            horizontalCenter: headingColumn.horizontalCenter
            bottom: headingColumn.top
            bottomMargin: Theme.paddingLarge
        }
        visible: !root._inputOrCancelEnabled && !root.emergency

        source: "image://theme/icon-m-device-lock?" + headingLabel.color
    }

    Column {
        id: headingColumn

        property int availableSpace: pinInput.y

        y: root._inputOrCancelEnabled || root.emergency
           ? Math.min(availableSpace/4 + headingVerticalOffset, availableSpace - height - Theme.paddingMedium)
           : (parent.height / 2) - headingLabel.height - subHeadingLabel.height
        width: (root._twoColumnMode ? parent.width / 2 : parent.width)
               - x - (root._twoColumnMode ? Theme.paddingLarge : x)
        x: Theme.horizontalPageMargin
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
            id: subHeadingLabel

            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: headingLabel.color
            visible: root._inputOrCancelEnabled || root.emergency
            font.pixelSize: Theme.fontSizeLarge
            text: root.subTitleText
        }

        BusyIndicator {
            running: root.busy
            visible: running
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Medium
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: root.warningTextColor
            visible: text !== ""

            font.pixelSize: root._inputOrCancelEnabled ? Theme.fontSizeSmall : Theme.fontSizeMedium
            text: {
                if (root.emergency) {
                    return root._emergencyWarningText
                } else if (root.transientWarningText !== "") {
                    return root.transientWarningText
                } else if (root._pinValidationWarningText !== "") {
                    return root._pinValidationWarningText
                } else {
                    return root.warningText
                }
            }
        }
    }

    TextInput {
        id: pinInput

        readonly property bool interactive: root.emergency || (root.inputEnabled
                && root.requirePin
                && !(root.suggestionsEnabled && root.suggestionsEnforced && root.suggestionVisible))

        x: Theme.horizontalPageMargin
        y: root._twoColumnMode ? Math.round(parent.height * 0.75) - height
                               : Math.min(keypad.y, root.height - Theme.itemSizeSmall) - height - (Theme.itemSizeSmall / 2)

        width: backspace.x - x - Theme.paddingSmall

        horizontalAlignment: Text.AlignRight

        focus: true
        // avoid virtual keyboard
        readOnly: inputMethodHints & (Qt.ImhDigitsOnly | Qt.ImhDialableCharactersOnly)
        enabled: interactive

        echoMode: root.emergency || (root.suggestionsEnabled && root.suggestionVisible)
                  ? TextInput.Normal
                  : TextInput.Password
        passwordCharacter: "\u2022"
        passwordMaskDelay: 1000
        cursorDelegate: Item {}

        selectionColor: "transparent"
        selectedTextColor: color

        persistentSelection: true

        color: root.emergency ? "white" : root.pinDisplayColor
        font.pixelSize: Theme.fontSizeHuge * 1.5

        inputMethodHints: {
            var hints = Qt.ImhNoPredictiveText
                    | Qt.ImhSensitiveData
                    | Qt.ImhNoAutoUppercase
                    | Qt.ImhHiddenText
                    | Qt.ImhMultiLine // This stops the text input hiding the keyboard when enter is pressed.
            if (root.emergency
                    || (root.inputEnabled && root.suggestionsEnabled && root.suggestionsEnforced && root.suggestionVisible)
                    || (!root.inputEnabled && root.showCancelButton && root.cancelText !== "")) {
                hints |= Qt.ImhDigitsOnly
            } else if (root.inputEnabled) {
                hints |= root.inputMethodHints
            }
            return hints
        }

        EnterKey.enabled: length >= minimumLength
        EnterKey.iconSource: "image://theme/icon-m-enter-accept"

        onTextChanged: root.transientWarningText = ""

        onAccepted: root._clickedConfirmButton()

        validator: RegExpValidator {
            regExp: {
                if (pinInput.inputMethodHints & Qt.ImhDigitsOnly) {
                    return /[0-9]*/
                } else if (pinInput.inputMethodHints & Qt.ImhLatinOnly) {
                    return /[ -~¡-ÿ]*/
                } else {
                    return  /.*/
                }
            }
        }

        // readOnly property disables all key handling except return for accepting.
        // have some explicit handling here. also disallows moving the invisible cursor which is nice.
        Keys.onPressed: {
            if (!readOnly) {
                return
            }

            var text = event.text
            if (text.length == 1 && "0123456789".indexOf(text) >= 0) {
                _handleNumberPress(text)
            } else if (event.key == Qt.Key_Escape) {
                _handleCancelPress()
            } else if (event.key == Qt.Key_Backspace) {
                _popPinDigit()
            }
        }

        MouseArea {
            anchors.fill: pinInput
            onClicked: pinInput.forceActiveFocus()
        }
    }

    OpacityRampEffect {
        sourceItem: pinInput

        enabled: pinInput.contentWidth > pinInput.width - (offset * pinInput.width)

        direction:  OpacityRamp.RightToLeft
        slope: 1 + 6 * pinInput.width / Screen.width
        offset: 1 - 1 / slope
    }

    IconButton {
        id: emergencyButton

        anchors {
            horizontalCenter: root._inputOrCancelEnabled
                              ? option1Button.horizontalCenter
                              : root.horizontalCenter
            verticalCenter: root._inputOrCancelEnabled
                    ? pinInput.verticalCenter
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
        states: State {
            when: root._twoColumnMode && root._inputOrCancelEnabled
            AnchorChanges {
                target: emergencyButton
                anchors.left: headingColumn.left
                anchors.horizontalCenter: undefined
            }
        }

        enabled: showEmergencyButton && !root.emergency && pinInput.length < 5
        opacity: enabled ? 1 : 0
        icon.source: "image://theme/icon-lockscreen-emergency-call"
        icon.color: undefined

        Behavior on opacity { FadeAnimator {} }

        onClicked: {
            root.enteredPin = ""
            root.emergency = !root.emergency
            root._feedback()
        }
    }

    IconButton {
        x: Theme.itemSizeSmall
        anchors.verticalCenter: pinInput.verticalCenter
        height: pinInput.height + pinInput.anchors.bottomMargin
        enabled: !showEmergencyButton && !_showDigitPad && pinInput.length < 5
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

    IconButton {
        id: backspace

        anchors {
            horizontalCenter: option2Button.horizontalCenter
            verticalCenter: pinInput.verticalCenter
            verticalCenterOffset: Theme.paddingMedium
        }
        states: State {
            when: root._twoColumnMode
            AnchorChanges {
                target: backspace
                anchors.right: headingColumn.right
                anchors.horizontalCenter: undefined
            }
        }

        height: pinInput.height + Theme.paddingMedium // increase reactive area
        icon {
            source: root._showSuggestionButton
                ? "image://theme/icon-m-reload"
                : "image://theme/icon-m-backspace-keypad"
            color: {
                if (root.emergency) {
                    return root.emergencyTextColor
                } else if (!root.dimmerBackspace) {
                    return Theme.primaryColor
                } else if (Theme.colorScheme == Theme.LightOnDark) {
                    return Theme.highlightDimmerColor
                } else {
                    return Theme.lightPrimaryColor
                }
            }
            highlightColor: root.emergency ? Theme.lightPrimaryColor : Theme.highlightColor
        }

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
            if (pinInput.length > 0) {
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
            if (pinInput.length === 0) {
                stop()
            }
        }
    }

    Keypad {
        id: keypad

        y: root.height + pageStack.panelSize - height - (Screen.sizeCategory > Screen.Medium && pageStack.currentPage.isPortrait
                            ? 2 * Theme.paddingLarge
                            : Theme.paddingLarge)
        anchors.right: parent.right
        width: root._twoColumnMode ? parent.width / 2 : parent.width

        symbolsVisible: pinInput.inputMethodHints & Qt.ImhDialableCharactersOnly
        visible: opacity > 0
        opacity: root.requirePin && pinInput.inputMethodHints & (Qt.ImhDigitsOnly | Qt.ImhDialableCharactersOnly) ? 1 : 0
        textColor: {
            if (root.emergency) {
                return root.emergencyTextColor
            } else if (pinInput.interactive) {
                return root.keypadTextColor
            } else {
                return Theme.highlightColor
            }
        }

        pressedTextColor: root.emergency ? "black" : (Theme.colorScheme === Theme.LightOnDark ? Theme.highlightColor : Theme.highlightDimmerColor)
        pressedButtonColor: root.emergency
                            ? "white"
                            : Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        enabled: pinInput.activeFocus
        onPressed:  {
            root._feedback()
            _handleNumberPress(number)
        }
    }

    PinInputOptionButton {
        id: option1Button
        visible: (keypad.visible || !root.requirePin)
                && text !== ""
                && (showCancelButton || root.emergency)

        anchors {
            left: keypad.left
            leftMargin: keypad._horizontalPadding
            bottom: keypad.bottom
            bottomMargin: icon.visible ? 0 : (keypad._buttonHeight - height) / 2
        }
        primaryColor: keypad.textColor
        width: keypad._buttonWidth
        height: icon.visible ? keypad._buttonHeight : width / 2
        emergency: root.emergency
        text: root.emergency
              ? //: Cancels out of the emergency call mode and returns to the PIN input screen
                //% "Cancel"
                qsTrId("settings_pin-bt-cancel_emergency_call")
              : root.cancelText

        icon {
            visible: !root.emergency
            source: "image://theme/icon-m-cancel"
        }

        onClicked: {
            root._feedback()
            _handleCancelPress()
        }
    }

    PinInputOptionButton {
        id: option2Button

        primaryColor: option1Button.primaryColor
        visible: (keypad.visible || !root.requirePin)
                && text !== ""
                && ((root.showOkButton && root.inputEnabled) || root.emergency)

        anchors {
            right: keypad.right
            rightMargin: keypad._horizontalPadding
            bottom: keypad.bottom
            bottomMargin: icon.visible ? 0 : (keypad._buttonHeight - height) / 2
        }
        width: option1Button.width
        height: icon.visible ? keypad._buttonHeight : width / 2
        emergency: root.emergency
        text: {
            if (root.emergency) {
                //: Starts the phone call
                //% "Call"
                return qsTrId("settings_pin-bt-start_call")
            } else if (root.requirePin && (pinInput.length < minimumLength
                       || _pinMismatch
                       || (root.enteringNewPin && root._oldPin !== "" && root._oldPin === root.enteredPin))) {
                return ""
            } else {
                return root.okText
            }
        }
        showWhiteBackgroundByDefault: root.emergency
        icon {
            visible: text == root.okText
            source: "image://theme/icon-m-accept"
        }

        onClicked: {
            root._feedback()
            if (root.emergency) {
                root._dialEmergencyNumber()
            } else {
                root._clickedConfirmButton()
            }
        }
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

    Component.onCompleted: {
        // Avoid hard dependency to feedback
        _feedbackEffect = Qt.createQmlObject("import QtQuick 2.0; import QtFeedback 5.0; ThemeEffect { effect: ThemeEffect.PressWeak }",
                           root, 'ThemeEffect');
    }
}
