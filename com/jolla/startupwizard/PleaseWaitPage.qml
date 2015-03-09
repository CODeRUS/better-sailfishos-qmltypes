import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

Page {
    backNavigation: false

    StartupWizardManager {
        id: wizardManager
    }

    Label {
        anchors {
            centerIn: parent
            verticalCenterOffset: -Theme.paddingLarge*2
        }
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - x*2
        wrapMode: Text.WordWrap

        //% "Please wait"
        text: qsTrId("startupwizard-la-please_wait")
        font.pixelSize: Theme.fontSizeExtraLarge
        color: wizardManager.defaultHighlightColor()
    }
}
