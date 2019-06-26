import QtQuick 2.0
import Sailfish.Mdm 1.0

Item {
    property var translationIds: {
        "title": "sailfish-mdm-he-sailfish_device_manager",
        "summary": "sailfish-mdm-la-mdm_installed",
        "body": "sailfish-mdm-la-if_remove_mdm",
        "triggerAccept": "sailfish-mdm-bt-i_understand"
    }

    function translate(textId) {
        switch (textId) {
            case "title":
                //% "Sailfish Device Manager"
                return qsTrId("sailfish-mdm-he-sailfish_device_manager")
            case "summary":
                //% "Mobile Device Management (MDM) services have been installed on this device, which can be used to remotely manage the device."
                return qsTrId("sailfish-mdm-la-mdm_installed")
            case "body":
                //% "If you wish to remove the Device Management services please contact a system administrator."
                return qsTrId("sailfish-mdm-la-if_remove_mdm")
            case "triggerAccept":
                //% "I understand"
                return qsTrId("sailfish-mdm-bt-i_understand")
            default:
                return ""
        }
    }
}
