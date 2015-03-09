import QtQuick 2.0
import Sailfish.Silica 1.0

InteractionHintLabel {
    property Page settingsPage: parent
    property bool hintShown

    anchors.bottom: parent.bottom
    opacity: touchInteractionHint.running ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation { duration: 1000 } }

    //: User does not have to do an explicit 'save' action; settings are automatically saved when they are changed.
    //% "Account settings will be automatically saved when changed."
    text: qsTrId("components_accounts-la-settings_autosave_hint")

    Connections {
        target: settingsPage
        onStatusChanged: {
            if (!hintShown && settingsPage.status == PageStatus.Active) {
                hintShown = true
                touchInteractionHint.running = true
            }
        }
    }

    // Not shown, just used to show the hint text for a duration consistent with interaction hints
    // elsewhere.
    TouchInteractionHint {
        id: touchInteractionHint
        visible: false
    }
}
