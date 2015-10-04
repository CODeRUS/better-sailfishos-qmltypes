import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    x: Theme.horizontalPageMargin
    width: parent.width - 2*Theme.horizontalPageMargin
    wrapMode: Text.Wrap
    textFormat: Text.StyledText
    color: Theme.highlightColor
    font.pixelSize: Theme.fontSizeExtraSmall
    linkColor: Theme.primaryColor
    onLinkActivated: {
        Qt.openUrlExternally(link)
    }
}
