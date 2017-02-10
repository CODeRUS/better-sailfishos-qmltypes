import QtQuick 2.0
import Sailfish.Silica 1.0
import org.kde.bluezqt 1.0 as BluezQt

ViewPlaceholder {
    property QtObject _bluetoothManager : BluezQt.Manager

    enabled: _bluetoothManager.adapters.length == 0

    //: Shown when system Bluetooth functionality is not available
    //% "Bluetooth not available"
    text: qsTrId("components_bluetooth-la-bluetooth_not_available")
}
