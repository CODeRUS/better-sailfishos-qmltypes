import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

Dialog {
    id: root

    signal clicked()

    function _dummyForTranslations() {
        //% "Ahoy! Welcome!"
        return qsTrId("startupwizard-la-ahoy_welcome")
    }

    StartupWizardManager {
        id: wizardManager
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            x: Theme.paddingLarge
            y: Theme.paddingLarge
            width: root.width - x*2

            Repeater {
                model: LanguageModel {}

                Label {
                    width: contentColumn.width
                    height: implicitHeight
                    font.pixelSize: Theme.fontSizeLarge
                    fontSizeMode: Text.Fit
                    color: wizardManager.defaultHighlightColor()
                    text: wizardManager.translatedText("startupwizard-la-ahoy_welcome", model.locale)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
    }
}
