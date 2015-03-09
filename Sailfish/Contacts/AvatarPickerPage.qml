import QtQuick 2.0
import Sailfish.Pickers 1.0 as Pickers

Pickers.AvatarPickerPage {
    id: root

    signal avatarUrlChanged(string avatarUrl)

    onAvatarSourceChanged: root.avatarUrlChanged(avatarSource)
}
