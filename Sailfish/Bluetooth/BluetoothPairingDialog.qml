import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0

Dialog {
    id: root

    // UI set-up
    property int mode: -1
    property int requestDirection: BluetoothAgent.IncomingPairingRequest
    property string errorMessage
    property string deviceAddress
    property int deviceClass
    property string deviceName
    property string passkey
    property bool allowPasskeyChange

    // settings entered/modified by user
    property string enteredPasskey
    property bool allowAutoConnect

    signal passkeyChangePending()
    signal passkeyChangeRequested(string newPasskey)

    function justWorksPairingSucceeded(bluetoothDevice) {
        // override everything with the 'success' screen
        busyIndicator.running = false
        canAccept = true
        justWorksPairedComponent.createObject(root, {"bluetoothDevice": bluetoothDevice})
    }

    //=== internal/private members follow

    property string _deviceDisplayName: deviceName.length ? deviceName : deviceAddress
    property bool _showPasskeyChangeOptions
    property bool _showLastPasskeyFailedMsg

    function forceUserChangePasskey(showFailureMessage) {
        passkeyOverrideInputField.text = ""
        _showLastPasskeyFailedMsg = showFailureMessage
        _showPasskeyChangeOptions = true
        passkeyChangePending()
    }

    function _resetPasskey() {
        passkeyChangeRequested(passkeyOverrideInputField.text)
        passkey = passkeyOverrideInputField.text
        _showPasskeyChangeOptions = false
    }

    function _instructionText() {
        switch (mode) {
        case BluetoothAgent.Compare:
            //: Inform user to confirm both Bluetooth devices display the same number before accepting this dialog.
            //% "Before continuing, confirm the same number is shown on both devices."
            return qsTrId("components_bluetooth-la-bluetooth_confirm_comparison")
        case BluetoothAgent.EnterPasskey:
        case BluetoothAgent.EnterPin:
        case BluetoothAgent.DisplayPasskey:
            if (requestDirection === BluetoothAgent.OutgoingPairingRequest
                    || mode == BluetoothAgent.DisplayPasskey) {
                  //: Inform user to enter the same passkey on the other Bluetooth device before accepting this dialog.
                  //% "Before continuing, enter the below passkey on the other device."
                return qsTrId("components_bluetooth-la-bluetooth_passkey_enter_as_sender")
            } else {
                  //: Inform user to enter the passkey from the other Bluetooth device before accepting this dialog.
                  //% "Before continuing, enter the passkey from the other device below."
                return qsTrId("components_bluetooth-la-bluetooth_passkey_enter_as_receipient")
            }
        default:
            return ""
        }
    }

    canAccept: mode >= 0
        && !_showPasskeyChangeOptions
        && ((mode == BluetoothAgent.Compare || mode == BluetoothAgent.DisplayPasskey) || passkey !== "" || inputField.text !== "")

    onDone: {
        root.focus = true
        if (result == DialogResult.Accepted) {
            if (mode == BluetoothAgent.EnterPin || mode == BluetoothAgent.EnterPasskey) {
                enteredPasskey = inputField.text
            }
            allowAutoConnect = autoConnectSwitch.checked
        }
    }

    Column {
        x: Theme.horizontalPageMargin
        y: Theme.itemSizeLarge
        width: parent.width - x*2
        opacity: root.errorMessage != "" ? 1 : 0

        Behavior on opacity { FadeAnimation {} }

        Label {
            width: parent.width
            height: implicitHeight + Theme.paddingLarge
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor

            //: Heading shown when a bluetooth pairing could not be created
            //% "Pairing error"
            text: qsTrId("components_bluetooth-he-pairing_error")
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            text: errorMessage
            color: Theme.rgba(Theme.highlightColor, 0.6)
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width
        visible: busyIndicator.running
        spacing: Theme.paddingLarge

        Label {
            x: Theme.horizontalPageMargin
            width: root.width - x*2
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            //: Shown while establishing connection to a bluetooth device for pairing
            //% "Connecting..."
            text: qsTrId("components_bluetooth-he-pairing_connecting")
        }

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: root.mode < 0 && root.errorMessage == ""
        }
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: contentColumn.height
        opacity: root.mode >= 0 && root.errorMessage == "" ? 1 : 0

        Behavior on opacity { FadeAnimation {} }

        PullDownMenu {
            visible: enabled
            enabled: allowPasskeyChange && !_showPasskeyChangeOptions && errorMessage === ""

            MenuItem {
                //: Show options to allow the user to change the Bluetooth passkey for pairing
                //% "Change passkey"
                text: qsTrId("components_bluetooth-me-change_passkey_menu")
                onClicked: {
                    root.forceUserChangePasskey(false)
                }
            }
        }

        Column {
            id: contentColumn

            width: root.width

            DialogHeader {
                id: header
                dialog: root
            }

            Label {
                id: title
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: implicitHeight + Theme.paddingLarge
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.WordWrap

                //: Requests the user to confirm whether to pair with another Bluetooth device
                //% "Pair with %1?"
                text: qsTrId("components_bluetooth-he-bluetooth_confirm_pairing_header").arg(root._deviceDisplayName)
            }

            Column {
                width: parent.width
                visible: !_showPasskeyChangeOptions
                opacity: !_showPasskeyChangeOptions ? 1 : 0

                Behavior on opacity { FadeAnimation {} }

                Label {
                    id: instructions
                    x: Theme.horizontalPageMargin
                    width: parent.width - x*2
                    color: Theme.rgba(Theme.highlightColor, 0.6)
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    text: root._instructionText()
                }

                Label {
                    id: readOnlyPasskey
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - Theme.horizontalPageMargin*2
                    height: implicitHeight + Theme.paddingLarge
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    wrapMode: Text.WrapAnywhere
                    visible: text != ""

                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: root.passkey
                }

                TextField {
                    id: inputField
                    width: parent.width

                    //: Label for the input field that allows the user to enter a PIN code for Bluetooth pairing
                    //% "Pairing PIN"
                    label: qsTrId("components_bluetooth-la-bluetooth_pin_label")
                    placeholderText: label
                    visible: (root.mode == BluetoothAgent.EnterPasskey || root.mode == BluetoothAgent.EnterPin)
                             && root.passkey == ""
                             && root.errorMessage == ""
                             && !root._showPasskeyChangeOptions
                    focus: visible

                    inputMethodHints: root.mode == BluetoothAgent.EnterPasskey
                            ? Qt.ImhFormattedNumbersOnly
                            : (Qt.ImhNoPredictiveText | Qt.ImhPreferNumbers)

                    EnterKey.enabled: text || inputMethodComposing
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: root.focus = true
                }

                BluetoothDeviceTypeComboBox {
                    width: root.width
                    deviceAddress: root.deviceAddress
                    deviceClass: root.deviceClass

                    onPressed: {
                        root.focus = true
                    }
                }

                TrustBluetoothDeviceSwitch {
                    id: autoConnectSwitch
                    checked: true
                }
            }

            Column {
                id: passkeyChangeContent

                width: root.width
                opacity: _showPasskeyChangeOptions ? 1 : 0

                Behavior on opacity { FadeAnimation {} }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - x*2
                    color: Theme.rgba(Theme.highlightColor, 0.6)
                    wrapMode: Text.WordWrap

                    text: root._showLastPasskeyFailedMsg
                            //: Displayed when a Bluetooth pairing attempt failed with the specified passkey (%1 = the specified passkey). User may try again by entering a new passkey.
                            //% "Authentication with passkey '%1' failed. Enter a new passkey and try again."
                          ? qsTrId("components_bluetooth-la-bluetooth_enter_new_passkey").arg(root.passkey)
                            //: Displayed above the textfield where user enters the Bluetooth pairing passkey
                            //% "Enter the pairing passkey below."
                          : qsTrId("components_bluetooth-la-bluetooth_enter_passkey")
                }

                TextField {
                    id: passkeyOverrideInputField
                    width: parent.width
                    visible: _showPasskeyChangeOptions && root.errorMessage == ""
                    focus: visible

                    //: Label for textfield where user enters the Bluetooth pairing passkey
                    //% "Passkey"
                    label: qsTrId("components_bluetooth-la-bluetooth_passkey_field")
                    placeholderText: label
                    inputMethodHints: inputField.inputMethodHints

                    EnterKey.enabled: text || inputMethodComposing
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: root._resetPasskey()
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter

                    //% "Change passkey"
                    text: qsTrId("components_bluetooth-bt-bluetooth_change_passkey")
                    enabled: passkeyOverrideInputField.text !== ""

                    onClicked: {
                        root._resetPasskey()
                    }
                }
            }
        }
    }

    Component {
        id: justWorksPairedComponent

        Column {
            property var bluetoothDevice

            y: Theme.itemSizeLarge
            width: root.width
            spacing: Theme.paddingLarge

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor

                //: Shown when successfully created a bluetooth pairing with another device
                //% "Pairing successful"
                text: qsTrId("components_bluetooth-he-pairing_success")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                wrapMode: Text.Wrap
                color: Theme.rgba(Theme.highlightColor, 0.6)

                //: Shown when successfully created a bluetooth pairing with another device (%1 = name of other device)
                //% "Now paired with %1."
                text: qsTrId("components_bluetooth-la-pairing_success").arg(bluetoothDevice && bluetoothDevice.name.length ? bluetoothDevice.name : (bluetoothDevice ? bluetoothDevice.address : ""))
            }

            BluetoothDeviceTypeComboBox {
                width: root.width
                deviceAddress: bluetoothDevice ? bluetoothDevice.address : ""
                deviceClass: bluetoothDevice ? bluetoothDevice.classOfDevice : 0
            }

            TrustBluetoothDeviceSwitch {
                id: autoConnectSwitch
                checked: true
                onCheckedChanged: {
                    root.allowAutoConnect = checked
                }
                Component.onCompleted: {
                    root.allowAutoConnect = checked
                }
            }
        }
    }
}
