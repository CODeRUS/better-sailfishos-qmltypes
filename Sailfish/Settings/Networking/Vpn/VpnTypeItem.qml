import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Settings.Networking.Vpn 1.0

BackgroundItem {
    property string vpnType
    property alias name: nameLabel.text
    property alias description: descriptionLabel.text
    property Page _mainPage
    property bool handleClick: vpnType.length > 0

    onClicked: if (handleClick) pageStack.animatorPush(VpnTypes.editDialogPath(vpnType), { newConnection: true, acceptDestination: _mainPage })

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
