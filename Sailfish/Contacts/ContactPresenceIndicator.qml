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
            return Theme.presenceColor(Theme.PresenceOffline)
        }
        switch (presenceState) {
            case Person.PresenceAvailable: return Theme.presenceColor(Theme.PresenceAvailable)
            case Person.PresenceBusy: return Theme.presenceColor(Theme.PresenceBusy)
            default: return Theme.presenceColor(Theme.PresenceAway)
        }
    }

    Behavior on color {
        id: colorAnimation
        ColorAnimation { }
    }
}
