import QtQuick 2.0
import Sailfish.Silica 1.0
import "./Units.js" as Units
import NemoMobile.Vault 1.0

Grid {
    id: self

    signal ready
    signal error(variant err)

    columns: Math.floor(width / Theme.itemSizeExtraLarge)

    function done() {
        for (var i = 0; i < units.count; ++i)
            units.get(i).unitState = "";
        ready();
    }

    function addUnit(name, info) {
        var index = units.count;
        info.iconName = info.icon;
        info.selected = true;
        info.unitState = "";
        var translation = info.translation;
        info.translation = translation ? qsTrId(translation) : info.name;
        units.append(info);
        return index;
    }

    function listSelected() {
        var res = []
        for (var i = 0; i < units.count; ++i) {
            var data = units.get(i)
            if (data.selected)
                res.push(data.name)
        }
        return res
    }

    function setStatus(name, status) {
        var v = units.get(Units.get(name));
        v.unitState = status;
    }

    property bool loading: false
    Connections {
        target: vault
        onDone: {
            if (loading && operation == Vault.Connect) {
                loading = false;
                Units.reload(addUnit, ready)
            }
        }
        onError: {
            if (loading && operation == Vault.Connect) {
                loading = false;
                self.error(error);
            }
        }
    }

    function load(reconnect) {
        console.log("Reloading units...");
        units.clear();
        loading = true;
        vault.connectVault(reconnect);
    }

    Repeater {
        model: ListModel { id: units }
        UnitSwitch {
            width: Theme.itemSizeExtraLarge

            icon.source: "image://theme/" + iconName
            label: translation
            checked: selected
            onClicked: {
                state === "" && units.setProperty(index, "selected", !selected)
            }
            state: unitState
        }
    }
}
