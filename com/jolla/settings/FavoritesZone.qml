import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.configuration 1.0

Column {
    id: root
    width: screen.width
    spacing: Theme.paddingLarge

    property Item _menu

    function showContextMenu(settingEntryPath, menuParent) {
        if (_menu == null) {
            _menu = contextMenuComponent.createObject(root)
        }
        _menu.settingEntryPath = settingEntryPath
        _menu.show(menuParent)
    }

    Component {
        id: contextMenuComponent
        FavoriteMenu {
            x: parent ? -parent.x : 0
            width: root.width
            isFavorite: true
        }
    }

    Grid {
        id: gridFavorites
        columns: 4
        width: root.width

        Repeater {
            model: FavoritesModel { filter: "grid_favorites" }

            delegate: Item {
                id: gridWrapper
                property bool menuOpen: root._menu !== null && root._menu.parent === gridWrapper
                height: menuOpen ? gridLoader.height + root._menu.height : gridLoader.height
                width: gridLoader.width
                SettingComponentLoader {
                    id: gridLoader
                    width: root.width / 4
                    height: width
                    settingsObject: model.object
                    gridMode: true
                    onContextMenuRequested: root.showContextMenu(settingEntryPath, gridWrapper)

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onPressAndHold: {
                            if (gridLoader.item && gridLoader.item.entryPath)
                                root.showContextMenu(gridLoader.item.entryPath, gridWrapper)
                        }
                    }
                }
                Binding {
                    target: gridLoader.item
                    property: "highlighted"
                    value: gridLoader.item.down || gridWrapper.menuOpen
                }
                Binding {
                    target: gridLoader.item
                    property: "_backgroundColor"
                    value: Theme.rgba(Theme.highlightBackgroundColor, gridLoader.item.down && !gridWrapper.menuOpen ?
                                          Theme.highlightBackgroundOpacity : 0)
                }
            }
        }
    }

    Column {
        width: root.width
        Repeater {
            model: FavoritesModel { filter: "list_favorites" }
            delegate: Item {
                id: listWrapper
                property bool menuOpen: root._menu !== null && root._menu.parent === listWrapper
                height: menuOpen ? listLoader.height + root._menu.height : listLoader.height
                width: root.width
                SettingComponentLoader {
                    id: listLoader
                    width: root.width
                    settingsObject: model.object
                    onContextMenuRequested: root.showContextMenu(settingEntryPath, listWrapper)

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onPressAndHold: {
                            if (listLoader.item && listLoader.item.entryPath)
                                root.showContextMenu(listLoader.item.entryPath, listWrapper)
                        }
                    }
                }
                Binding {
                    target: listLoader.item
                    property: "highlighted"
                    value: listLoader.item.down || listWrapper.menuOpen
                }
                Binding {
                    target: listLoader.item
                    property: "_backgroundColor"
                    value: Theme.rgba(Theme.highlightBackgroundColor, listLoader.item.down && !listWrapper.menuOpen ?
                                          Theme.highlightBackgroundOpacity : 0)
                }
            }
        }
    }
}
