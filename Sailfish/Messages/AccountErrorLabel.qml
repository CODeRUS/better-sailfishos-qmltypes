import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Messages 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.messages.internal 1.0

Item {
    id: errorBanner
    height: 0
    opacity: 0

    property string localUid
    property var account: MessageUtils.telepathyAccounts.ready
                          ? MessageUtils.telepathyAccounts.getAccount(localUid)
                          : null
    property string customErrorText

    readonly property bool sendingSMS: MessageUtils.isSMS(localUid)
    readonly property string simErrorState: (sendingSMS || !MessageUtils.hasModem) ? simError.errorState : ""

    property real padding: Theme.paddingMedium

    function errorText() {
        // If there is no modem, assume that the SIM is the problem
        if (sendingSMS && !MessageUtils.hasModem) {
            //: The SIM in the device does not support sending messages
            //% "SIM card does not support SMS/MMS"
            return qsTrId("messages-la-sim_card_support")
        }

        if (simErrorState) {
            return simError.errorString
        }

        if (customErrorText) {
            return customErrorText
        }

        var text
        if (!account || account.connectionStatus === TelepathyAccount.Connected) {
            //: %1 is provider name, e.g. Google
            //% "Connected to %1"
            text = qsTrId("messages-la-im_account_connected")
        } else if (account.connectionStatus === TelepathyAccount.Connecting) {
            //: %1 is provider name, e.g. Google
            //% "Connecting to %1..."
            text = qsTrId("messages-la-im_account_connecting")
        } else {
            switch (account.connectionStatusReason) {
                case TelepathyAccount.ReasonRequested:
                    //: %1 is provider name, e.g. Google
                    //% "You are offline on %1"
                    text = qsTrId("messages-la-im_account_offline")
                    break
                case TelepathyAccount.ReasonNetworkError:
                    //: %1 is provider name, e.g. Google
                    //% "Unable to connect to %1 due to a network error"
                    text = qsTrId("messages-la-im_network_error")
                    break
                case TelepathyAccount.ReasonAuthenticationFailed:
                    //: %1 is provider name, e.g. Google
                    //% "%1 authentication failed<br>Check your username and password"
                    text = qsTrId("messages-la-im_authentication_error")
                    break
                case TelepathyAccount.ReasonEncryptionError:
                    //: %1 is provider name, e.g. Google
                    //% "Unable to connect to %1 due to an encryption error"
                    text = qsTrId("messages-la-im_encryption_error")
                    break
                case TelepathyAccount.ReasonNoneSpecified:
                default:
                    //: %1 is provider name, e.g. Google
                    //% "Unable to connect to %1<br>Check your connection and settings"
                    text = qsTrId("messages-la-im_generic_error")
                    break
            }
        }

        return text.arg(account ? account.displayName : "")
    }

    ErrorLabel {
        id: label
        highlight: mouseArea.pressed && mouseArea.containsMouse
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: Theme.paddingSmall
        }
        text: errorText()
    }

    SimErrorState {
        id: simError

        multiSimManager: MessageUtils.simManager
        modemPath: MessageUtils.voiceModemPath
    }

    MouseArea {
        id: mouseArea
        enabled: simErrorState
        anchors.fill: parent
        onClicked: MessageUtils.testCanUseSim(simErrorState)
    }

    states: State {
        name: "error"
        when: (account && account.connectionStatus !== TelepathyAccount.Connected)
              || (simErrorState && sendingSMS)
              || customErrorText

        PropertyChanges {
            target: errorBanner
            height: label.implicitHeight + errorBanner.padding
            opacity: 1
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}

