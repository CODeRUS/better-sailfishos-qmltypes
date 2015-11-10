import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

Page {
    id: root

    property string localeName
    property StartupWizardManager startupWizardManager

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -Theme.paddingLarge*2
        }
        spacing: Theme.paddingMedium

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://theme/icon-os-state-update?" + startupWizardManager.defaultHighlightColor()
        }

        Label {
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - Theme.horizontalPageMargin
            wrapMode: Text.Wrap
            textFormat: Text.StyledText // render <br>

            text: {
                //: Shown when Sailfish OS is starting up
                //% "Starting,<br>please wait"
                qsTrId("startupwizard-la-starting_sailfish_please_wait") // trigger Qt Linguist translation
                return startupWizardManager.translatedText("startupwizard-la-starting_sailfish_please_wait", root.localeName)
            }
            font.pixelSize: Theme.fontSizeLarge
            color: startupWizardManager.defaultHighlightColor()
        }
    }
}
