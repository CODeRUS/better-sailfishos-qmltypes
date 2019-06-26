import QtQuick 2.0
import Sailfish.Pickers.private 1.0 as PickersPrivate

PickersPrivate.AvatarPickerPage {
    id: root

    signal avatarUrlChanged(string avatarUrl)

    onAvatarSourceChanged: root.avatarUrlChanged(avatarSource)
}
