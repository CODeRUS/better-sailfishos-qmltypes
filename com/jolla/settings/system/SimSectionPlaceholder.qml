import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import org.nemomobile.dbus 2.0

/*
  This provides a placeholder item to be shown when a SIM is inactive or not present.
  */
Item {
    id: root

    property alias multiSimManager: errorState.multiSimManager

    property alias valid: errorState.valid

    property alias modemPath: errorState.modemPath
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin

    property alias simManager: errorState.simManager
    property alias showSimActivation: errorState.simActivationRequired

    property alias modemDisabled: errorState.modemDisabled

    width: parent.width
    height: enabled
            ? activationButton.y + ((activationButton.visible || busyIndicator.running) ? activationButton.height + Theme.paddingLarge : 0)
            : 0
    enabled: modemPath.length > 0
             && (mainLabel.text.length > 0 || busyIndicator.running)

    opacity: enabled ? 1 : 0
    Behavior on opacity { enabled: valid; FadeAnimation { duration: 500 } }

    SimErrorState {
        id: errorState
        Component.onCompleted: mainLabel.text = errorState.errorString
        onErrorStringChanged: {
            if (busyIndicator.running) {
                delayedErrorChange.start()
            } else {
                mainLabel.text = errorState.errorString
            }
        }
    }

    Timer {
        id: delayedErrorChange
        interval: 1000
        onTriggered: {
            if (mainLabel.text != errorState.errorString) {
                mainLabel.text = errorState.errorString
                busyIndicator.running = false
            } else {
                restart()
            }
        }
    }

    Label {
        id: mainLabel
        x: root.leftMargin
        width: parent.width - root.leftMargin - root.rightMargin
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeLarge
        font.family: Theme.fontFamilyHeading
    }

    BusyIndicator {
        id: busyIndicator
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if ((Qt.application.active && root.showSimActivation)
                    || !Qt.application.active) {
                // stop the busy indicator if user canceled the SIM PIN input
                busyIndicator.running = false
            }
        }
    }

    Button {
        id: activationButton
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        visible: text.length > 0
        preferredWidth: Theme.buttonWidthMedium
        text: {
            if (errorState.errorState == "modemDisabled") {
                //% "Enable"
                return qsTrId("settings_system-bt-enable_sim")
            }
            if (root.showSimActivation) {
                //: Unlock SIM card (enter pin/puk)
                //% "Unlock"
                return qsTrId("settings_system-bt-unlock_sim")
            }
            return ""
        }

        onClicked: {
            if (errorState.errorState == "modemDisabled") {
                if (multiSimManager) {
                    busyIndicator.running = true
                    multiSimManager.enableModem(root.modemPath, true)
                }
            } else if (root.showSimActivation) {
                busyIndicator.running = true
                pinQuery.call("requestSimPin", [ root.modemPath ])
            }
        }
    }

    DBusInterface {
        id: pinQuery
        service: "com.jolla.PinQuery"
        path: "/com/jolla/PinQuery"
        iface: "com.jolla.PinQuery"
    }
}
