import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0

MouseArea {
    id: switchItem

    property alias label: myLabel.text
    property alias icon: myIcon
    property bool checked
    property bool down: pressed && containsMouse

    height: column.height
    states: [
        State {
            name: "begin"
        }
        , State {
            name: "ok"
        }
        , State {
            name: "fail"
        }
    ]

    function getGlassColor() {
        switch(state) {
            case "begin":
                return "yellow"

            case "ok":
                return "green";

            case "fail":
                return "red";

            default:
            return down ? Theme.highlightColor : Theme.primaryColor
        }
    }

    Column {
        id: column
        anchors.centerIn: parent

        Item {
            height: Theme.itemSizeSmall - Theme.paddingLarge
            width: parent.width

            GlassItem {
                color: switchItem.getGlassColor()
                visible: switchItem.state === "" || checked
                anchors.horizontalCenter: parent.horizontalCenter
                dimmed: !down && !checked
                falloffRadius: checked ? undefined : 0.075
                anchors.centerIn: parent
            }
        }
        Image {
            id: myIcon
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item {
            width: parent.width
            height: Theme.paddingSmall
        }
        Label {
            id: myLabel
            color: down ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            horizontalAlignment: Text.AlignCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
