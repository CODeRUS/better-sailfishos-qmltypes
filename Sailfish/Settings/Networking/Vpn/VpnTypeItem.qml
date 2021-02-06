import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Settings.Networking.Vpn 1.0

BackgroundItem {
    property string _vpnType
    property alias name: nameLabel.text
    property alias description: descriptionLabel.text
    property Page _mainPage
    property bool canImport

    onClicked: {
        if (canImport) {
            pageStack.animatorPush(VpnTypes.importDialogPath(_vpnType), { _mainPage: _mainPage, _vpnType: _vpnType })
        } else {
            pageStack.animatorPush(VpnTypes.editDialogPath(_vpnType), { newConnection: true, acceptDestination: _mainPage, vpnType: _vpnType })
        }
    }

    height: Math.max(Theme.itemSizeLarge, column.height) + column.y * 2

    Column {
        id: column

        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        y: Theme.paddingMedium
        spacing: Theme.paddingSmall

        Label {
            id: nameLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeMedium
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }
        Label {
            id: descriptionLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        }
    }
}
