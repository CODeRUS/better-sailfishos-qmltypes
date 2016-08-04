import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: root

    property var lastBackupDateTime

    signal triggerUpdate()

    width: parent ? parent.width : Screen.width

    Label {
        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        height: implicitHeight + Theme.paddingLarge
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryColor

        //: Indicates the last date and time that a backup was created. %1 = locale-specific date text, %2 = locale-specific time text
        //% "Backup created %1 %2"
        text: qsTrId("vault-la-backup_created").arg(Format.formatDate(lastBackupDateTime, Format.DateMedium)).arg(Format.formatDate(lastBackupDateTime, Format.TimeValue))
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        preferredWidth: Theme.buttonWidthLarge

        // (reuse this translation to avoid adding a new one)
        //: Major heading on the page which lets the user select which backup they wish to migrate to the new format.
        //% "Update your backup"
        text: qsTrId("vault-he-update_your_backup")

        onClicked: {
            root.triggerUpdate()
        }
    }
}
