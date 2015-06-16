import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    anchors.fill: parent

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentIndex = 1
        timeline.restart()
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                fader.opacity = 0.8
                //% "Here is Phone app"
                appInfo.text = qsTrId("tutorial-la-phone_app")
                appInfo.opacity = 1.0
            }
        }
        PauseAnimation { duration: 3000 }
        ScriptAction  {
            script: {
                appInfo.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Tap to open"
                appInfo.text = qsTrId("tutorial-la-tap_to_open")
                appInfo.opacity = 1.0
                phoneIcon.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: openAppAnimation
        NumberAnimation {
            target: fader
            property: "opacity"
            to: 0.0
            duration: 100
        }
        NumberAnimation {
            target: background
            property: "contentY"
            to: 780
            duration: 200
        }
        NumberAnimation {
            target: appMainPage
            property: "opacity"
            to: 1.0
            duration: 500
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Main view shows call history"
                hintLabel.text = qsTrId("tutorial-la-call_history")
                hintLabel.opacity = 1.0
            }
        }
        PauseAnimation { duration: 3000 }
        ScriptAction  {
            script: {
                hintLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "The glow on top of the view indicates pulley menu which has additional options"
                hintLabel.text = qsTrId("tutorial-la-pulley_menu_description")
                hintLabel.opacity = 1.0
                hintLabel.showGradient = false
                pulleyMenu.busy = true
                continueButton.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        ScriptAction  {
            script: {
                hintLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //: 'Enter phone number' must match with voicecall-ph-enter_phone_number
                //% "Pull down slowly without lifting your finger and select<br>'Enter phone number'"
                hintLabel.text = qsTrId("tutorial-la-pull_down_slowly")
                hintLabel.opacity = 1.0
                hintLabel.opacityFadeDuration = 500 // quicker fade for cross-fade with overlayLabel
                hintLabel.showGradient = true
                pulleyMenu.busy = false
                hint.running = true
                touchBlocker.enabled = false
            }
        }
    }

    SequentialAnimation {
        id: timeline3
        NumberAnimation {
            target: dialer
            property: "y"
            to: root.height - dialer.height
            duration: 500
            easing.type: Easing.OutQuad
        }
        ScriptAction  {
            script: {
                touchBlocker.enabled = true
                background.returnToBounds()
                closeAnimation.restart()
                lessonCompleted()
            }
        }
    }

    SequentialAnimation {
        id: closeAnimation
        PauseAnimation { duration: 500 }
        FadeAnimation {
            target: root
            to: 0.0
            duration: 2000
        }
    }

    DimmedRegion {
        id: fader
        anchors.fill: parent
        color: tutorialTheme.highlightDimmerColor
        opacity: 0.0
        target: mainPage
        area: Qt.rect(0, 0, parent.width, parent.height)
        exclude: [ phoneIcon ]

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    BackgroundItem {
        id: phoneIcon
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width / 4
        height: 1.25 * width
        enabled: false
        highlighted: false
        z: 2 // has to be higher than flickable and touchBlocker

        onClicked: {
            enabled = false
            timeline.stop()
            appInfo.opacity = 0.0
            openAppAnimation.start()
        }
    }

    TapInteractionHint {
        running: phoneIcon.enabled && appInfo.opacity === 1.0
        anchors.centerIn: phoneIcon
    }

    InfoLabel {
        id: appInfo
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: phoneIcon.top
            bottomMargin: 2 * Theme.paddingLarge
        }
        opacity: 0.0
        color: tutorialTheme.highlightColor
        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    Image {
        id: appMainPage
        source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-app-background.png")
        sourceSize {
            width: 540 * xScale
            height: 960 * yScale
        }
        width: sourceSize.width
        height: sourceSize.height
        opacity: 0.0
    }

    SilicaFlickable {
        id: flickable
        anchors {
            fill: parent
            bottomMargin: root.height - dialer.y
        }
        contentHeight: height
        opacity: appMainPage.opacity
        clip: true

        Column {
            id: content
            width: flickable.width

            Item {
                width: 1; height: Theme.paddingLarge
            }

            Item {
                id: numberField
                height: Theme.itemSizeSmall
                width: parent.width
                visible: false

                Image {
                    // Added for preventing hard-coded values
                    id: imagePlaceholder
                    source: "image://theme/icon-m-missed-call"
                    visible: false
                }

                TextField {
                    id: textField
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingSmall // Just a visual tweak
                        left: imagePlaceholder.right
                        leftMargin: -Theme.horizontalPageMargin // Compensate internal margin
                        right: parent.right
                    }
                    background: null
                    color: tutorialTheme.highlightColor
                    placeholderColor: tutorialTheme.secondaryHighlightColor
                    enableSoftwareInputPanel: false
                    //: Needs to match with voicecall-ph-enter_phone_number
                    //% "enter phone number"
                    placeholderText: qsTrId("tutorial-ph-enter_phone_number")

                }

                Label {
                    text: "12:18"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: tutorialTheme.highlightColor
                    anchors {
                        rightMargin: Theme.horizontalPageMargin
                        right: parent.right
                        top: textField.top
                        // Position center of the upper part of TextField
                        topMargin: Theme.paddingMedium
                    }
                }

            }
            Repeater {
                model: callLogModel
                delegate: Item {
                    width: flickable.width
                    height: Theme.itemSizeSmall + Theme.paddingMedium

                    Image {
                        id: directionIcon
                        anchors {
                            left: parent.left
                            top: firstNameLabel.top
                        }
                        source: model.type === 1
                                ? "image://theme/icon-m-incoming-call"
                                : model.type === 2
                                  ? "image://theme/icon-m-missed-call"
                                  : ""
                    }

                    Label {
                        id: firstNameLabel
                        anchors {
                            left: parent.left
                            leftMargin: 42
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -Theme.paddingMedium
                        }
                        text: model.firstName
                    }

                    Label {
                        id: lastNameLabel
                        anchors {
                            left: firstNameLabel.right
                            leftMargin: Theme.paddingSmall
                            baseline: firstNameLabel.baseline
                        }
                        color: tutorialTheme.secondaryColor
                        text: model.lastName
                    }

                    Label {
                        id: timeLabel
                        anchors {
                            right: parent.right
                            rightMargin: Theme.horizontalPageMargin
                            baseline: firstNameLabel.baseline
                        }
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: model.time
                    }
                }
            }
        }

        HintLabel {
            id: hintLabel
            opacity: 0.0
        }

        Rectangle {
            // Extra dimmer when overlay label is visible
            width: flickable.width
            height: flickable.height
            color: tutorialTheme.highlightDimmerColor
            opacity: 0.7 * overlayLabel.opacity
        }

        PullDownMenu {
            id: pulleyMenu

            property bool locked: pulleyMenu._atFinalPosition && !flickable.dragging
            property bool wasLocked

            highlightColor: tutorialTheme.highlightColor
            backgroundColor: tutorialTheme.highlightBackgroundColor

            onLockedChanged: {
                if (locked) {
                    // Remember the "locked" state until the menu is closed
                    wasLocked = true
                    pulleyHideTimer.restart()
                }
            }

            on_BounceBackRunningChanged: {
                if (_bounceBackRunning) {
                    if (!numberField.visible) {
                        hintLabel.opacity = 1.0
                        hint.running = true
                    }
                    overlayLabel.opacity = 0.0
                }
            }

            onActiveChanged: {
                if (!numberField.visible) {
                    hintLabel.opacity = active ? 0.0 : 1.0
                    overlayLabel.opacity = active ? 1.0 : 0.0
                    hint.running = active ? false : true
                }
                if (!active) {
                    // Forget the "locked" state
                    wasLocked = false
                    pulleyHideTimer.stop()
                }
            }

            MenuItem {
                id: dialerOption
                //: Needs to match with voicecall-me-enter_phone_number
                //% "Enter phone number"
                text: qsTrId("tutorial-me-enter_phone_number")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
                onClicked: {
                    if (!pulleyMenu.wasLocked) {
                        numberField.visible = true
                        textField.forceActiveFocus()
                        timeline3.restart()
                    }
                }
            }

            MenuItem {
                //: Needs to match with voicecall-me-call_person
                //% "Call person"
                text: qsTrId("tutorial-me-call_person")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
            }
        }
    }

    Rectangle {
        anchors.fill: dialer
        color: Theme.rgba(tutorialTheme.highlightBackgroundColor, 0.3)
    }

    Column {
        id: dialer
        width: parent.width
        y: parent.height

        Item {
            // Magic number copied from DialerList.qml (in voicecall-ui)
            height: 47 + Theme.paddingLarge
            width: parent.width
        }

        Keypad {
            voiceMailIconSource: "image://theme/icon-phone-dialer-voicemail"
        }

        Button {
            //: Needs to match with voicecall-bt-call
            //% "Call"
            text: qsTrId("tutorial-bt-call")
            height: Theme.itemSizeLarge
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Down
        loops: Animation.Infinite
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        id: touchBlocker
        anchors.fill: parent
        preventStealing: true
    }

    Button {
        id: continueButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 4 * Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        color: tutorialTheme.primaryColor
        highlightColor: tutorialTheme.highlightColor
        opacity: enabled ? hintLabel.opacity : 0
        enabled: false
        //% "Got it!"
        text: qsTrId("tutorial-bt-got_it")

        onClicked: {
            enabled = false
            timeline2.restart()
        }
    }

    InfoLabel {
        id: overlayLabel
        parent: __silica_applicationwindow_instance
        y: 4 * Theme.paddingLarge - flickable.contentY
        color: tutorialTheme.highlightColor
        opacity: 0.0

        text: pulleyMenu.locked
              //% "Pull down slower"
              ? qsTrId("tutorial-la-pull_slower")
              : pulleyMenu.active && !pulleyMenu.wasLocked
                //% "Select by releasing your finger when the option is highlighted"
                ? qsTrId("tutorial-la-select_enter_phone_number")
                : ""

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    Timer {
        id: pulleyHideTimer
        interval: 2000
        onTriggered: {
            pulleyMenu.hide()
        }
    }

    ListModel {
        id: callLogModel
        // Includes a few extra items that are not visible on 540 x 960 display
        ListElement { type: 0; firstName: "Michael"; lastName: "Brasser"; time: "11:53" }
        ListElement { type: 1; firstName: "Soumya"; lastName: "Bijjal"; time: "11:05" }
        ListElement { type: 2; firstName: "Juha"; lastName: "Paakkari"; time: "10:20" }
        ListElement { type: 0; firstName: "Bernd"; lastName: "Wachter"; time: "Yesterday" }
        ListElement { type: 0; firstName: "Carsten"; lastName: "Munk"; time: "Yesterday" }
        ListElement { type: 0; firstName: "Stefano"; lastName: "Mosconi"; time: "Tuesday" }
        ListElement { type: 0; firstName: "Marc"; lastName: "Dillon"; time: "Tuesday" }
        ListElement { type: 1; firstName: "Niels"; lastName: "Breet"; time: "Tuesday" }
        ListElement { type: 0; firstName: "Robin"; lastName: "Brurchell"; time: "Tuesday" }
        ListElement { type: 1; firstName: "陈怡因"; lastName: ""; time: "Monday" }
        ListElement { type: 1; firstName: "Jaakko"; lastName: "Roppola"; time: "Monday" }
        ListElement { type: 0; firstName: "Chris"; lastName: "Adams"; time: "Monday" }
    }
}
