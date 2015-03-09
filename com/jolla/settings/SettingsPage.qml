import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.configuration 1.0

Page {
    id: page

    property string name
    property string entryPath
    property int depth

    property Item _menu: null

    function showContextMenu(settingEntryPath, viewItem) {
        if (_menu == null) {
            _menu = contextMenuComponent.createObject(listView)
        }
        _menu.settingEntryPath = settingEntryPath
        _menu.isFavorite = favorites.isFavorite(settingEntryPath)
        _menu.show(viewItem)
    }

    SilicaListView {
        id: listView

        anchors.fill: parent

        model: SettingsModel {
            path: page.entryPath.split("/")
            depth: page.depth
        }

        header: PageHeader {
            title: page.name
        }

        delegate: Item {
            id: wrapper
            property bool menuOpen: page._menu !== null && page._menu.parent === wrapper
            height: menuOpen ? loaderObj.height + page._menu.height : loaderObj.height
            width: parent.width
            SettingComponentLoader {
                id: loaderObj
                settingsObject: model.object

                onContextMenuRequested: page.showContextMenu(settingEntryPath, wrapper)
            }
            Binding {
                target: loaderObj.item
                property: "highlighted"
                value: loaderObj.item.down || wrapper.menuOpen
            }
            Binding {
                target: loaderObj.item
                property: "_backgroundColor"
                value: Theme.rgba(Theme.highlightBackgroundColor, loaderObj.item.down && !wrapper.menuOpen ?
                                      Theme.highlightBackgroundOpacity : 0)
            }
        }

        section.property: page.depth > 1 ? "category" : ""
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader { text: section }

        VerticalScrollDecorator {}
    }

    Component {
        id: contextMenuComponent
        FavoriteMenu {
        }
    }
}
