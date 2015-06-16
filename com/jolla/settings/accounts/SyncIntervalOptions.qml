import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Column {
    id: root

    property var intervalModel

    width: parent.width

    signal intervalClicked(int accountSyncInterval, string intervalText)

    Repeater {
        model: root.intervalModel

        ListItem {
            width: root.width
            height: Theme.itemSizeSmall

            Label {
                id: label
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                }
                text: root.intervalModel.intervalText(model.interval)
            }

            onClicked: {
                root.intervalClicked(model.interval, label.text)
            }
        }
    }
}
