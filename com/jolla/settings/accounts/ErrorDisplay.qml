import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias heading: headingLabel.text
    property alias description: descriptionLabel.text

    property bool showSettingsError

    opacity: 0

    Behavior on opacity { FadeAnimation {} }

    Label {
        id: headingLabel
        x: Theme.paddingLarge
        width: parent.width - x*2
        height: implicitHeight + Theme.paddingLarge
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraLarge
        color: Theme.highlightColor

        text: root.showSettingsError
                //: Account settings not available
                //% "Settings not available"
              ? qsTrId("components_accounts-he-account_settings_error")
              : root.heading
    }

    Label {
        id: descriptionLabel
        anchors.top: headingLabel.bottom
        x: Theme.paddingLarge
        width: parent.width - x*2
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.highlightColor

        text: root.showSettingsError
                //: Error message displayed when account details cannot be loaded
                //% "Unable to load account details."
              ? qsTrId("components_accounts-la-account_settings_error")
              : root.description
    }
}
