import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.Telephony 1.0

// TODO: replace with standard component

Item {
    id: simPicker

    property int actionType: Telephony.Call
    property alias showBackground: background.visible

    width: parent.width
    implicitHeight: simSelector.y + simSelector.height + Theme.paddingLarge

    signal simSelected(int sim, string modemPath)

    function simInfo(sim) {
        return simSelector.simInfo(sim)
    }

    SilicaPrivate.GlassBackground {
        id: background
        anchors.fill: parent
        visible: false
    }

    Label {
        id: label
        y: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.highlightColor
        text: actionType == Telephony.Call
              //% "Call via"
              ? qsTrId("sailfish-telephony-la-call-via")
              //% "Send via"
              : qsTrId("sailfish-telephony-la-send-via")
    }

    SimSelector {
        id: simSelector
        y: Theme.itemSizeSmall
        updateSelectedSim: false

        onSimSelected: simPicker.simSelected(sim, modemPath)
    }
}
