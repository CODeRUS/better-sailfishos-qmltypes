import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0

Dialog {
    id: dialog

    property string path
    canAccept: folderName.text.length > 0
    onAccepted: {
        if (!FileEngine.mkdir(path, folderName.text, true)) {
            //% "Cannot create folder %1"
            errorNotification.show(qsTrId("filemanager-la-cannot_create_folder").arg(folderName.text))
        }
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            DialogHeader {
                //% "Create"
                acceptText: qsTrId("filemanager-he-create")
            }
            TextField {
                id: folderName
                width: parent.width
                //% "New folder"
                placeholderText: qsTrId("filemanager-la-new_folder")
                label: placeholderText
                focus: true

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: dialog.accept()
            }
        }
        VerticalScrollDecorator {}
    }
}
