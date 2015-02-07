import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

Page {
    id: root

    property LanguageModel languageModel: LanguageModel {}

    signal languageClicked(string language, string locale)

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            //% "Language"
            title: qsTrId("settings_system-he-language")
        }
        model: root.languageModel
        currentIndex: languageModel.currentIndex
        delegate: BackgroundItem {
            id: delegateItem
            width: ListView.view.width

            onClicked: root.languageClicked(model.name, model.locale)

            Label {
                x: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - x*2
                wrapMode: Text.Wrap
                text: model.name
                color: (delegateItem.highlighted || delegateItem.ListView.isCurrentItem)
                       ? Theme.highlightColor
                       : Theme.primaryColor
            }
        }
        VerticalScrollDecorator {}
    }
}
