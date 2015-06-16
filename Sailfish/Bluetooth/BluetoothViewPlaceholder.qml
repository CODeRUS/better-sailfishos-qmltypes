import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0

Label {
    enabled: !bluezMonitor.available

    anchors.centerIn: parent
    visible: enabled
    width: parent.width - Theme.horizontalPageMargin*2
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    font {
        pixelSize: Theme.fontSizeExtraLarge
        family: Theme.fontFamilyHeading
    }
    color: Theme.highlightColor
    opacity: 0.6

    //: Shown when system Bluetooth functionality is not available
    //% "Bluetooth not available"
    text: qsTrId("components_bluetooth-la-bluetooth_not_available")

    BluezMonitor {
        id: bluezMonitor
    }
}
