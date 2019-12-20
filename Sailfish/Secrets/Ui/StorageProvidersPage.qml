import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Secrets.Ui 1.0

Page {
    id: root
    signal selected(string name)

    SilicaListView {
        anchors.fill: parent
        header: PageHeader {
            //% "Providers"
            title: qsTrId("secrets_ui-he-providers")
        }
        model: StorageProvidersModel {}
        delegate: ListItem {
            onClicked: root.selected(model.name)
            Label {
                text: model.name
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        VerticalScrollDecorator {}
    }
}
