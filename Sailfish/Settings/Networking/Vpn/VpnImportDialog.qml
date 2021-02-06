import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking 1.0
import Sailfish.Settings.Networking.Vpn 1.0

Dialog {
    id: root

    property Page _mainPage
    property string title
    property string failTitle
    property string message
    property string failMessage
    property bool importFailed
    property var nameFilters
    property string _vpnType

    canAccept: false
    forwardNavigation: false

    Column {
        width: parent.width

        DialogHeader {
            id: pageHeader
            title: importFailed ? failTitle : root.title

            acceptText: ''
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - x*2

            text: importFailed ? failMessage : message

            textFormat: Text.StyledText
            wrapMode: Text.Wrap

            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
        }
    }

    ButtonLayout {
        anchors {
            bottom: parent.bottom
            bottomMargin: importButton.height
            horizontalCenter: parent.horizontalCenter
        }

        preferredWidth: Theme.buttonWidthLarge

        Button {
            id: importButton

            text: (importFailed ?
                //% "Try again"
                qsTrId("settings_network-bt-import_file_try_again") :
                //% "Import file"
                qsTrId("settings_network-bt-import_file"))
            onClicked: {
                var obj = pageStack.animatorPush("Sailfish.Pickers.FilePickerPage", {
                    nameFilters: root.nameFilters,
                    popOnSelection: false
                })
                obj.pageCompleted.connect(function(picker) {
                    picker.selectedContentPropertiesChanged.connect(function() {
                        var importer = Qt.createComponent(VpnTypes.importPath(_vpnType)).createObject()
                        var path = picker.selectedContentProperties['filePath']
                        VpnTypes.importFile(pageStack, _mainPage, path, _vpnType, importer.parseFile)
                    })
                })
            }
        }

        Button {
            ButtonLayout.newLine: true

            //% "Skip"
            text: qsTrId("settings_network-bt-skip_import")
            onClicked: {
                pageStack.animatorReplace(VpnTypes.editDialogPath(_vpnType), {
                    newConnection: true,
                    acceptDestination: _mainPage,
                    vpnType: _vpnType
                })
            }
        }
    }
}
