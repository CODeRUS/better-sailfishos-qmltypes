import QtQuick 2.0
import Sailfish.Silica 1.0
// Load translations
import com.jolla.settings 1.0

ContextMenu {
    id: contextMenu

    property string settingEntryPath
    property bool isFavorite

    MenuItem {
        text: contextMenu.isFavorite
              ? //% "Remove from Favorites"
                qsTrId("settings-me-remove_from_favorites")
              : //% "Add to Favorites"
                qsTrId("settings-me-add_to_favorites")

        onClicked: {
            if (contextMenu.isFavorite) {
                favorites.removeFavorite(contextMenu.settingEntryPath)
            } else {
                favorites.addFavorite(contextMenu.settingEntryPath)
            }
        }
    }
}
