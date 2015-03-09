import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Rectangle {
    property int presenceState
    property bool offline: (presenceState === Person.PresenceUnknown) || (presenceState === Person.PresenceHidden) || (presenceState === Person.PresenceOffline)
    property alias animationEnabled: colorAnimation.enabled

    width: Theme.iconSizeSmall
    height: Theme.paddingSmall
    radius: Math.round(height/3)

    color: {
        if (offline) {
            return '#999999'
        }
        switch (presenceState) {
            case Person.PresenceAvailable: return '#00ff23'
            case Person.PresenceBusy: return '#ff0f00'
            default: return '#ffa600'
        }
    }

    Behavior on color {
        id: colorAnimation
        ColorAnimation { }
    }
}
