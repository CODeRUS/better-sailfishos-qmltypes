import QtQuick 2.0
import Sailfish.Silica 1.0
import "btutil.js" as BtUtil

Dialog {
    id: root

    // UI set-up
    property string deviceAddress
    property int deviceClass
    property string deviceName
    property string uuid

    // settings entered/modified by user
    property bool allowAutoConnect

    function canceledRequest() {
        canAccept = false
    }

    property var _serviceName: BtUtil.knownServiceUuids[uuid.toUpperCase()] // undefined if not found
    property string _deviceDisplayName: deviceName.length ? deviceName : deviceAddress

    onDone: {
        if (result == DialogResult.Accepted) {
            allowAutoConnect = autoConnectSwitch.checked
        }
    }

    Column {
        x: Theme.horizontalPageMargin
        y: Theme.itemSizeLarge
        width: parent.width - x*2
        opacity: !root.canAccept ? 1 : 0

        Behavior on opacity { FadeAnimation {} }

        Label {
            width: parent.width
            height: implicitHeight + Theme.paddingLarge
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor

            //: Heading shown when a bluetooth connection was not established because the other device canceled the connection request
            //% "Connection canceled"
            text: qsTrId("components_bluetooth-he-connection_canceled")
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.rgba(Theme.highlightColor, 0.6)
            font.pixelSize: Theme.fontSizeExtraSmall

            //: Shown when a bluetooth connection request was received but the other device canceled the request
            //% "The other device canceled the connection request."
            text: qsTrId("components_bluetooth-la-connection_request_canceled")
        }
    }

    Column {
        width: root.width
        visible: root.canAccept

        DialogHeader {
            dialog: root
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            height: implicitHeight + Theme.paddingLarge
            color: Theme.highlightColor
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeExtraLarge
            wrapMode: Text.Wrap

            text: (root._serviceName == undefined || root._serviceName == "")
                    //: Confirm whether another Bluetooth device should be allowed to connect to some Bluetooth service on this Jolla device (%1 = name of other device)
                    //% "Allow connection from %1?"
                  ? qsTrId("components_bluetooth-he-bluetooth_authorize_service_connection_to_unknown_service").arg(root._deviceDisplayName)
                    //: Confirm whether another Bluetooth device should be allowed to connect to the specified Bluetooth service on this Jolla device (%1 = name of other device, %2 = name of service)
                    //% "Allow %1 to connect to the %2 service?"
                  : qsTrId("components_bluetooth-he-bluetooth_authorize_service_connection_to_named_service").arg(root._deviceDisplayName).arg(root._serviceName)
        }

        TrustBluetoothDeviceSwitch {
            id: autoConnectSwitch
        }
    }
}
