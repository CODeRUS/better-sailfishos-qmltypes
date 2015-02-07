import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.systemsettings 1.0

SilicaListView {
    id: root

    property string locale

    signal localeClicked(string language)

    anchors.fill: parent

    delegate: BackgroundItem {
        id: delegateItem
        width: root.width
        highlighted: down

        onClicked: {
            root.locale = model.locale
            root.localeClicked(model.name)
        }

        Label {
            x: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            width: root.width - x*2
            text: model.name
            color: delegateItem.highlighted || root.locale === model.locale
                   ? wizardManager.defaultHighlightColor()
                   : wizardManager.defaultPrimaryColor()
        }
    }

    StartupWizardManager {
        id: wizardManager
    }

    VerticalScrollDecorator {}
}
