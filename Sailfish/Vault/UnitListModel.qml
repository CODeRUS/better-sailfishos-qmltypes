import QtQuick 2.0
import Sailfish.Silica 1.0
import NemoMobile.Vault 1.0

ListModel {
    id: root

    function loadVaultUnits(units) {
        for (var name in units) {
            var info = units[name]
            var translation = info.translation;
            var props = {
                "name": name,
                "displayName": (info.translation ? qsTrId(info.translation) : info.name),
                "iconSource": (info.icon ? "image://theme/" + info.icon : ""),
                "group": info.group,
                "script": info.script
            }
            append(props)
        }
    }

    function getUnitValue(unitName, propertyName, defaultValue) {
        for (var i=0; i<count; i++) {
            var data = get(i)
            if (data.name == unitName) {
                return data[propertyName]
            }
        }
        return defaultValue
    }
}
