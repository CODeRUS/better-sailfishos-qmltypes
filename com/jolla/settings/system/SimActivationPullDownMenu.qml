import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import MeeGo.QOfono 0.2
import MeeGo.Connman 0.2
import org.nemomobile.dbus 2.0
import org.nemomobile.ofono 1.0

/*
  This provides a pulley menu for activating flight mode, and also for
  activating SIMs for single-modem devices.
  */
PullDownMenu {
    id: root

    property var multiSimManager

    property bool showFlightModeAction: networkManagerFactory.instance.offlineMode
    property bool showSimActivation: (modemManager.availableModems.length <= 1)
            && (simManager.pinRequired === OfonoSimManager.SimPin || simManager.pinRequired === OfonoSimManager.SimPuk)

    property string modemPath: (Telephony.multiSimSupported || modemManager.availableModems.length == 0) ? "" : modemManager.availableModems[0]
    property NetworkManagerFactory networkManagerFactory: NetworkManagerFactory {}
    property OfonoModemManager modemManager: OfonoModemManager {}
    property OfonoSimManager simManager: OfonoSimManager { modemPath: root.modemPath }

    property QtObject _pinQuery: DBusInterface {
        service: "com.jolla.PinQuery"
        path: "/com/jolla/PinQuery"
        iface: "com.jolla.PinQuery"
    }

    visible: showFlightModeAction || showSimActivation

    MenuItem {
        //% "Turn off flight mode"
        text: qsTrId("settings_system-me-flight_mode_off")
        visible: root.showFlightModeAction
        onClicked: networkManagerFactory.instance.offlineMode = false
    }

    MenuItem {
        //: Unlock SIM card (enter pin/puk)
        //% "Unlock SIM card"
        text: qsTrId("settings_system-me-unlock_sim_card")
        visible: root.showSimActivation
        onClicked: _pinQuery.call("requestSimPin", [])
    }
}
