import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias progressText: validationProgressLabel.text
    property bool errorHighlight
    property bool hasValidValue

    property QtObject textField
    property Flickable flickable
    property bool validating
    property bool autoValidate
    property int autoValidationTimeout: hasValidValue ? 100 : 2500   // validate more quickly if we know it is correct

    // if textfield has a label, only show error banner when the textfield has text, else there
    // would be an odd gap between the textfield text and the banner
    readonly property bool progressDisplayed: (!textField || !textField.labelVisible || textField.text.length > 0) && validationProgressLabel.text.length

    signal validationRequested()
    signal validationCanceled()

    function validate() {
        if (!validating && (!textField || textField.text != _lastCheckedText)) {
            if (textField) {
                _lastCheckedText = textField.text
            }
            validationRequested()
        }
    }

    function validateLater() {
        if (!validating) {
            validationTimer.restart()
        }
    }

    function clear() {
        validationTimer.stop()
        validating = false
    }

    function validateAndFocusNextField(nextTextField, focusOnlyIfValid) {
        _focusOnlyIfValid = focusOnlyIfValid
        if (hasValidValue) {
            nextTextField.focus = true
        } else {
            if (!hasValidValue) {
                validate()
            }
            _nextTextFieldToFocus = nextTextField
        }
    }

    property real _expandedHeight: validationProgressLabel.implicitHeight + Theme.paddingLarge*2
    property real _prevHeight: 0
    property real _flickableContentYAtOpen
    property string _lastCheckedText
    property QtObject _nextTextFieldToFocus
    property bool _focusOnlyIfValid

    width: parent.width
    height: progressDisplayed ? _expandedHeight : 0
    clip: true

    onProgressDisplayedChanged: {
        if (progressDisplayed && flickable) {
            _flickableContentYAtOpen = flickable.contentY
        }
    }

    onHeightChanged: {
        // ensure progressText banner is within flickable's visible area
        if (flickable) {
            if (height > _prevHeight) {
                var moveY = height
                if (_nextTextFieldToFocus && !_focusOnlyIfValid) {
                    moveY += _nextTextFieldToFocus.height
                }
                flickable.contentY = Math.max(root.mapToItem(flickable.contentItem, 0, moveY).y - flickable.height, _flickableContentYAtOpen)
            }
            _prevHeight = height
        }
        if (_nextTextFieldToFocus && progressDisplayed && Math.ceil(height) == _expandedHeight
                && !(_focusOnlyIfValid && !hasValidValue)) {
            _nextTextFieldToFocus.focus = true
            _nextTextFieldToFocus = null
        }
    }

    Behavior on height { NumberAnimation {} }

    Timer {
        id: validationTimer
        interval: root.autoValidationTimeout
        onTriggered: {
            root.validate()
        }
    }

    Connections {
        target: textField
        onActiveFocusChanged: {
            if (!textField.activeFocus && root.autoValidate) {
                root.validate()
            }
        }
        onTextChanged: {
            if (validating) {
                root.clear()
                root.validationCanceled()
            } else {
                validationTimer.stop()
                if (textField.text.length == 0) {
                    clear()
                    progressText = ""
                }
            }
            if (root.autoValidate) {
                root.validateLater()
            }
        }
    }

    Rectangle {
        anchors {
            fill: parent
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingMedium
        }

        color: root.errorHighlight
               ? Theme.rgba("#ff4d4d", Theme.highlightBackgroundOpacity)  // as per TextBase
               : Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

        Behavior on color { ColorAnimation {} }
    }

    Label {
        id: validationProgressLabel
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: busyIndicator.running ? busyIndicator.left : parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraSmall
        color: root.errorHighlight
               ? "#ff4d4d"  // as per TextBase
               : Theme.highlightColor
    }

    BusyIndicator {
        id: busyIndicator
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        size: BusyIndicatorSize.ExtraSmall
        running: root.validating
    }
}
