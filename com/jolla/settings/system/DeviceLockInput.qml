import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.QOfono 0.2
import org.nemomobile.lipstick 0.1
import com.jolla.settings.system 1.0
import org.nemomobile.configuration 1.0

Item {
    id: root

    DeviceLockSettings {
        id: lockSettings
    }

    // new properties
    property bool useMaze: !root.hasOwnProperty("simManager")
    onUseMazeChanged: {
        if (!_showDigitPad && !useMaze) {
            alphanumProxy.forceActiveFocus()
        }
    }
    property int captchaLine: 1
    property bool captcha: false
    onCaptchaChanged: {
        if (captcha) {
            captchaLine = Math.floor((Math.random() * mazeLock.pinx) + 1)
        }
    }
    Connections {
       target: root
       ignoreUnknownSignals: true
       onAttemptChanged: {
           if (attempt > 2 && parseInt(attempt % 3) == 0) {
               root.captcha = true
           }
       }
    }

    // read-only
    property string enteredPin
    onEnteredPinChanged: {
        if (mazeLock.visible) {
            mazeLock.repaint()
        }
    }
    property bool emergency
    property bool enteringNewPin

    property bool showCancelButton: true
    property bool showOkButton: true
    property int minimumLength: lockSettings.codeMinLength
    property int maximumLength: lockSettings.codeMaxLength

    // modem for emergency calls
    property string modemPath: manager.defaultModem

    //: Confirms the entered PIN
    //% "Enter"
    property string okText: qsTrId("settings_pin-bt-enter_pin")

    //: Cancels PIN entry
    //% "Cancel"
    property string cancelText: qsTrId("settings_pin-bt-cancel_pin")

    property string titleText
    property color titleColor: Theme.secondaryHighlightColor
    property string warningText
    property color warningTextColor: Theme.primaryColor
    property bool highlightTitle
    property color pinDisplayColor: Theme.highlightColor
    property color keypadTextColor: Theme.primaryColor
    property bool dimmerBackspace
    property color emergencyTextColor: "red"

    property string _passwordCharacter: "\u2022"
    property string _displayedPin
    property string _oldPin
    property string _newPin

    property string _pinConfirmTitleText
    property string _badPinWarning
    property string _overridingTitleText
    property string _overridingWarningText
    property bool lastChance

    property bool showEmergencyButton: true

    //: Warns that the entered PIN was too long.
    //% "Lock code cannot be more than %n digits."
    property string pinLengthWarning: qsTrId("settings_devicelock-la-devicelock_max_length_warning", maximumLength)
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

    property bool showDigitPad: !lockSettings.codeInputIsKeyboard
    property bool _showDigitPad: emergency || (!useMaze && showDigitPad)
    property bool visibleInDashboard

    signal pinConfirmed()
    signal pinEntryCanceled()

    function clear() {
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
        if (!useMaze && ((keypad.visible && enteredPin == "62935625") || (alphanumProxy.visible && enteredPin == "mazelock"))) {
           useMaze = true
           enteredPin = ""
           _displayedPin = ""
        }
        else if (enteringNewPin) {
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
            if (captcha) {
                if (useMaze) {
                    var startPos = mazeLock.pinx * (captchaLine - 1) + 1
                    var captchaString = mazeLock.chars.substr(startPos, mazeLock.pinx)
                    if (enteredPin == captchaString) {
                        captcha = false
                    }
                    else {
                        var oldLine = captchaLine
                        while (captchaLine == oldLine) {
                            captchaLine = Math.floor((Math.random() * mazeLock.pinx) + 1)
                        }
                    }
                }
                else {
                    if (keypad.visible) {
                        if (enteredPin == "13795") {
                            captcha = false
                        }
                    }
                    else {
                        if (enteredPin == "jolla") {
                            captcha = false
                        }
                    }
                }
                
                if (captcha && _feedbackEffect) {
                    _feedbackEffect.play()
                }
                enteredPin = ""
                _displayedPin = ""
            }
            else {
                pinConfirmed()
            }
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
            if (maximumLength > 0 && enteredPin.length >= maximumLength) {
                _overridingWarningText = pinLengthWarning
                return
            }
            obfuscateLastDigit.stop()
            if (useMaze && enteringNewPin) {
               _displayedPin += digit
            }
            else {
               _displayedPin = _passwordString(_displayedPin.length) + (useMaze && mazeLockSettings.maskImmediately ? _passwordCharacter : digit)
               obfuscateLastDigit.start()
            }
            enteredPin += digit
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

    width: Math.min(parent.width, parent.height)
    height: width
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
            if (!root.emergency) {
                _displayedPin = _passwordString(_displayedPin.length)
            }
        }
    }

    Label {
        id: headingLabel
        y: Theme.itemSizeExtraSmall
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - Theme.paddingLarge * 2
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
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: headingLabel.bottom
        }
        width: parent.width - Theme.paddingLarge * 2
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        color: root.warningTextColor

        font.pixelSize: Theme.fontSizeSmall
        text: root.captcha ? (useMaze ? qsTr("Draw line number %1 to continue").arg(captchaLine) : (keypad.visible ? "Enter \"13795\" to continue" : "Enter \"jolla\" to continue"))
                           : root._overridingWarningText !== "" ? root._overridingWarningText : root.warningText
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

        anchors.horizontalCenter: option1Button.horizontalCenter
        anchors.verticalCenter: pinInputDisplay.verticalCenter
        enabled: showEmergencyButton && !root.emergency && root.enteredPin.length < 5
        opacity: enabled ? 1 : 0
        icon.source: "image://theme/icon-lock-emergency-call"

        Behavior on opacity { FadeAnimation {} }

        onClicked: {
            root.clear()
            root.emergency = !root.emergency
            if (_feedbackEffect) {
                _feedbackEffect.play()
            }
        }
    }
    IconButton {
        x: Theme.itemSizeSmall
        anchors.verticalCenter: pinInputDisplay.verticalCenter
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
            bottom: showEmergencyButton || keypad.visible ? keypad.top : (useMaze ? mazeLock.top : alphanumProxy.bottom)
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
        icon.source: "image://theme/icon-m-backspace" + (root.dimmerBackspace && !root.emergency ? "?" + Theme.highlightDimmerColor : "")

        opacity: root.enteredPin === "" ? 0 : 1
        enabled: opacity

        Behavior on opacity { FadeAnimation {} }

        onClicked: {
            root._popPinDigit()
        }
        onPressAndHold: {
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
        anchors {
            bottom: parent.bottom
            bottomMargin: screen.sizeCategory > Screen.Medium && pageStack.currentPage.isPortrait ? 2*Theme.paddingLarge
                                                                                                  : Theme.paddingLarge
        }
        symbolsVisible: false
        visible: opacity > 0
        opacity: _showDigitPad
        textColor: root.emergency ? root.emergencyTextColor : root.keypadTextColor
        pressedTextColor: root.emergency ? "black" : Theme.highlightColor
        pressedButtonColor: root.emergency
                            ? "white"
                            : Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

        onPressed: root._pushPinDigit(number + "")
    }

    // mazelock configuration settings. loaded once after lipstick start.
    ConfigurationGroup {
        id: mazeLockSettings
        path: "/desktop/nemo/devicelock/mazelock"
        property int size: 4
        property bool colored: true
        property bool maskImmediately: true
    }

    Item {
        id: mazeLock
        width: parent.width
        height: width
        visible: !emergency && useMaze
        anchors.bottom: parent.bottom

        property int pinx: showDigitPad ? 3 : (mazeLockSettings.size < 3 ? 3 : (mazeLockSettings.size > 6 ? 6 : mazeLockSettings.size))
        property int piny: pinx

        property var colors: ["#FFFFFF", "#FFFF80", "#FFFF00", "#FF80FF",
                              "#FF8080", "#FF8000", "#FF00FF", "#FF0080",
                              "#FF0000", "#80FFFF", "#80FF80", "#80FF00",
                              "#8080FF", "#808080", "#808000", "#8000FF",
                              "#800080", "#800000", "#00FFFF", "#00FF80",
                              "#00FF00", "#0080FF", "#008080", "#008000",
                              "#0000FF", "#000080", "#000000"]
        property string chars: "#1234567890abcdefghijklmnopqrstuvwxyz"
        //123
        //456
        //789

        //1234
        //5678
        //90ab
        //cdef

        //12345
        //67890
        //abcde
        //fghij
        //klmno

        //123456
        //7890ab
        //cdefgh
        //ijklmn
        //opqrst
        //uvwxyz

        function repaint() {
            canvas.requestPaint()
        }

        MouseArea {
            id: pinArea
            width: parent.width
            height: width
            anchors.centerIn: parent
            preventStealing: true

            Repeater {
               id: mazeCreator
               model: mazeLock.pinx * mazeLock.piny
               delegate: pinComponent
            }

            Canvas {
                id: canvas
                anchors.fill: parent
                z: 0

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.lineWidth = 4
                    ctx.beginPath()
                    if (root.enteredPin.length > 1) {
                        for (var i = 0; i < root.enteredPin.length; i++) {
                            var node = pinArea.getNode(mazeLock.chars.indexOf(root.enteredPin[i]))
                            var point = pinArea.getNodePoint(node.x, node.y)

                            if (i == 0) {
                                ctx.moveTo(point.x, point.y)
                            }
                            else {
                                ctx.strokeStyle = Theme.rgba(mazeLockSettings.colored ? mazeLock.colors[i] : Theme.primaryColor, 0.5)
                                ctx.lineTo(point.x, point.y)
                                ctx.stroke()
                                ctx.beginPath()
                                ctx.moveTo(point.x, point.y)
                            }
                        }
                    }
                }
            }

            signal activatePosition(int ax, int ay)

            function getNode(index) {
                var nodeX = parseInt(index % mazeLock.pinx) || mazeLock.pinx
                var nodeY = parseInt((index - 1) / mazeLock.piny) + 1
                return Qt.point(nodeX, nodeY)
            }

            function getNodePoint(px, py) {
                var posX = pinArea.width / (mazeLock.pinx + 1) * px
                var posY = pinArea.height / (mazeLock.piny + 1) * py
                return Qt.point(posX, posY)
            }

            function processItem(index, nodeX, nodeY) {
                if (root.enteredPin.length < 2) {
                    addNode(index, nodeX, nodeY)
                }
                else {
                    addNode(index, nodeX, nodeY)
                }
            }

            function addNode(index, nodeX, nodeY) {
                var nodeChar = mazeLock.chars.charAt(index)
                if (nodeChar != enteredPin.charAt(enteredPin.length - 1)) {
                    root._pushPinDigit(nodeChar)
                    canvas.requestPaint()
                }
            }

            function removeNode() {
                root._popPinDigit()
                canvas.requestPaint()
            }

            function cleanNodes() {
                while (root.enteredPin.length > 0) {
                    root._popPinDigit()
                }
                canvas.requestPaint()
            }

            onPressed: {
                cleanNodes()
            }

            onPressAndHold: {
                if (root.enteredPin.length == 0) { 
                    useMaze = false
                }
            }

            onPositionChanged: {
                activatePosition(mouse.x, mouse.y)
            }

            onReleased: {
                activatePosition(-1, -1)
                if (captcha) {
                    if (root.enteredPin.length >= mazeLock.pinx) {
                        root._clickedConfirmButton()
                    }
                }
                if (root.enteredPin.length > 4) {
                    root._clickedConfirmButton()
                }
            }
        }

        Component {
            id: pinComponent
            GlassItem {
                id: nodeItem
                property bool hovered: false
                property int activeSize: pinArea.width / (mazeLock.pinx + 1) * (2 / 3)
                property int size: 64 + (Math.min(4, (root.enteredPin.match(RegExp(mazeLock.chars[index + 1], "g")) || []).length) * 64)
                width: hovered ? 256 : size
                height: hovered ? 256 : size
                property var pinPoint: pinArea.getNode(index + 1)
                property var nodePoint: pinArea.getNodePoint(pinPoint.x, pinPoint.y)
                property int posX: nodePoint.x
                property int posY: nodePoint.y
                x: posX - width / 2
                y: posY - height / 2
                property int thresold: 8
                z: 10

                Connections {
                    target: pinArea
                    onActivatePosition: {
                        if (!hovered && ax >= posX - (activeSize / 2) + thresold
                                && ay >= posY - (activeSize / 2) + thresold
                                && ax <= posX + (activeSize / 2) - thresold
                                && ay <= posY + (activeSize / 2) - thresold) {

                            pinArea.processItem(index + 1, posX, posY)
                            hovered = true
                        }
                        else if (hovered && (ax < posX - (activeSize / 2)
                                     || ay < posY - (activeSize / 2)
                                     || ax > posX + (activeSize / 2)
                                     || ay > posY + (activeSize / 2))) {
                            hovered = false
                        }
                    }
                }
            }
        }
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

        visible: keypad.visible && text !== "" && showOkButton

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
              : (useMaze || root.enteredPin.length < minimumLength || !root._changedPinValid() ? "" : root.okText)
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
        visible: !keypad.visible && !useMaze
        y: Qt.inputMethod.keyboardRectangle.y - Theme.itemSizeSmall

        horizontalAlignment: TextInput.AlignHCenter
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhHiddenText
        focus: !keypad.visible && !useMaze
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
            else if (!focus) {
               root.forceActiveFocus()
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

    OfonoManager { id: manager }

    OfonoModem {
        id: modem
        modemPath: root.modemPath
    }

    OfonoVoiceCallManager { id: voiceCallManager }

    // To make an emergency call: (as per ofono emergency-call-handling.txt)
    // 1) Set org.ofono.Modem online=true
    // 2) Dial number using telephony VoiceCallManager
    function _dialEmergencyNumber() {
        root._overridingWarningText = ""
        if (!modem.online) {
            modem.onlineChanged.connect(_dialEmergencyNumber)
            modem.online = true
            return
        }
        modem.onlineChanged.disconnect(_dialEmergencyNumber)
        voiceCallManager.modemPath = modem.modemPath
        var emergencyNumbers = voiceCallManager.emergencyNumbers
        if (root.enteredPin !== "" && emergencyNumbers.indexOf(root.enteredPin) === -1) {
            //: Indicates that user has entered invalid emergency number
            //% "Only emergency calls  permitted"
            root._overridingWarningText = qsTrId("settings_pin-la-invalid_emergency_number")
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
        }
        _voiceCallManager.dial(_voiceCallManager.defaultProviderId, root.enteredPin)
    }

    function _resetView() {
        clear()
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
        if (!_showDigitPad && !useMaze) {
            alphanumProxy.forceActiveFocus()
        }
    }

    onVisibleInDashboardChanged: {
        if (!_showDigitPad && !useMaze && visibleInDashboard && enabled) {
            alphanumProxy.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        // Avoid hard dependency to feedback
        _feedbackEffect = Qt.createQmlObject("import QtQuick 2.0; import QtFeedback 5.0; ThemeEffect { effect: ThemeEffect.PressWeak }",
                           root, 'ThemeEffect');
    }
}
