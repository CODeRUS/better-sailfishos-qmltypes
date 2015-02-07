import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

StandardAccountSettingsDisplay {
    id: root

    onAccountInitialized: {
        if (autoEnableAccount) {
            var services = account.supportedServiceNames
            for (var i in services) {
                var service = accountManager.service(services[i])
                account.enableWithService(service.name)
            }
        }
    }

    Label {
        x: Theme.paddingLarge
        width: parent.width - x*2
        height: implicitHeight + Theme.paddingLarge*2
        wrapMode: Text.Wrap
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall

        //: Brief description for the Jolla account page
        //% "Your Jolla account is your pathway to applications and software updates."
        text: qsTrId("settings_accounts-la-jolla_account_description")
    }

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        source: "image://theme/graphic-store-jolla-apps"
    }
}
