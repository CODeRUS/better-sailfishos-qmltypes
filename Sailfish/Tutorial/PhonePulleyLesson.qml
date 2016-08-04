import QtQuick 2.0
import QtTest 1.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import "private"

Lesson {
    id: root

    readonly property real zoomedOutScale: 0.88
    property bool _demonstrated

    //% "Now you know that the line at the top of the view is the pulley menu and you learned how to call a phone number"
    recapText: qsTrId("tutorial-la-recap_phone_pulley_menu")

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentItem = background.switcherItem
        applicationGridIndicator.visible = false
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
                applicationGrid.y = 0
                touchBlocker.enabled = false
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
                //% "The line at the top of the view indicates pulley menu which has additional options"
                hintLabel.text = qsTrId("tutorial-la-pulley_menu_description")
                hintLabel.opacity = 1.0
                hintLabel.showGradient = false
                pulleyMenu.busy = true
            }
        }
        PauseAnimation { duration: 2000 }
        ScriptAction  {
            script: {
                playButton.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        ScriptAction  {
            script: {
                hint.stop()
                hintLabel.opacity = 0.0
                pulleyMenu.busy = false
                pulleyMenu.userAttempt = false
                playButton.enabled = false
            }
        }
        PauseAnimation { duration: 1000 }
        HandAnimation {
            hand: hand
            zoomItem: __silica_applicationwindow_instance._wallpaperItem
            zoomedOutScale: root.zoomedOutScale
            onPressed: {
                flickable.interactive = true
                touchInput.press()
            }
            onReleased: {
                touchInput.release()
                flickable.interactive = false
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Now it's your turn"
                hintLabel.text = qsTrId("tutorial-la-your_turn")
                hintLabel.opacity = 1.0
                hintLabel.showGradient = true
                root._demonstrated = true
            }
        }
        PauseAnimation { duration: 2000 }
        ScriptAction  {
            script: {
                hintLabel.opacity = 0.0
                timeline3.restart()
            }
        }
    }

    SequentialAnimation {
        id: timeline3
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
                pulleyMenu.userAttempt = true
                flickable.interactive = true
                hint.start()
                touchBlocker.enabled = false
            }
        }
    }

    SequentialAnimation {
        id: timeline4
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
                playButton.enabled = false
                closeAnimation.restart()
                lessonCompleted()
            }
        }
    }

    SequentialAnimation {
        id: closeAnimation
        PauseAnimation { duration: 500 }
        FadeAnimation {
            target: appMainPage
            to: 0.0
            duration: 2000
        }
    }

    Image {
        source: "image://theme/graphic-edge-swipe-handle-bottom"
        opacity: 1 - appMainPage.opacity
        anchors {
            bottom: applicationGrid.top
            horizontalCenter: applicationGrid.horizontalCenter
        }
    }

    Image {
        id: applicationGrid

        width: parent.width
        height: parent.height
        opacity: timeline2.running ? 0 : 1

        y: parent.height

        source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-launcher.png")

        Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    LauncherItem {
        id: phoneIcon

        row: 0
        column: 0

        enabled: applicationGrid.y === 0

        onClicked: {
            timeline.complete()
            touchBlocker.enabled = true
            enabled = false
            flickable.interactive = true
            timeline.stop()
            appInfo.opacity = 0.0
            applicationGrid.y = parent.height
            openAppAnimation.start()
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

    TapInteractionHint {
        running: phoneIcon.enabled && appInfo.opacity === 1.0
        anchors.centerIn: phoneIcon
    }

    InfoLabel {
        id: appInfo
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: phoneIcon.bottom
            topMargin: 2 * Theme.paddingLarge
        }
        opacity: 0.0
        color: tutorialTheme.highlightColor
        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    Image {
        id: appMainPage

        parent: applicationBackground
        source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-app-background.png")
        anchors.fill: parent
        opacity: 0.0
    }

    Flickable {
        id: flickable
        anchors {
            fill: parent
            bottomMargin: root.height - dialer.y
        }
        contentHeight: height
        opacity: appMainPage.opacity
        clip: true
        interactive: false

        // These are from SilicaFlickable, replicated here mainly so that we don't have BoundsBehavior
        property Item pullDownMenu
        property Item pushUpMenu
        property bool _pulleyDimmerActive: pullDownMenu && pullDownMenu._activeDimmer || pushUpMenu && pushUpMenu._activeDimmer
        pixelAligned: true
        pressDelay: 50
        boundsBehavior: (pullDownMenu && pullDownMenu._activationPermitted) || (pushUpMenu && pushUpMenu._activationPermitted)
                        ? Flickable.DragOverBounds : Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

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
                    source: "image://theme/icon-phone-missed-call"
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
                                ? "image://theme/icon-phone-incoming-call"
                                : model.type === 2
                                  ? "image://theme/icon-phone-missed-call"
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

        PullDownMenu {
            id: pulleyMenu

            property bool locked: pulleyMenu._atFinalPosition && !flickable.dragging
            property bool wasLocked
            property bool userAttempt

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
                if (userAttempt && _bounceBackRunning) {
                    if (!numberField.visible) {
                        hintLabel.opacity = 1.0
                        hint.start()
                    }
                    overlayLabel.opacity = 0.0
                }
            }

            onActiveChanged: {
                if (userAttempt) {
                    if (!numberField.visible) {
                        hintLabel.opacity = active ? 0.0 : 1.0
                        overlayLabel.opacity = active ? 1.0 : 0.0
                        if (active)
                            hint.stop()
                        else
                            hint.start()
                    }
                    if (!active) {
                        // Forget the "locked" state
                        wasLocked = false
                        pulleyHideTimer.stop()
                    }
                }
            }

            MenuItem {
                //: Needs to match with voicecall-me-enter_phone_number
                //% "Enter phone number"
                text: qsTrId("tutorial-me-enter_phone_number")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
                onClicked: {
                    if (pulleyMenu.userAttempt && !pulleyMenu.wasLocked) {
                        numberField.visible = true
                        textField.forceActiveFocus()
                        timeline4.restart()
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
        opacity: dialer.opacity
    }

    Column {
        id: dialer

        opacity: timeline2.running ? 0 : appMainPage.opacity
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
            color: tutorialTheme.primaryColor
            highlightColor: tutorialTheme.highlightColor
            highlightBackgroundColor: tutorialTheme.highlightBackgroundColor
        }
    }

    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Down
        interactionMode: TouchInteraction.Pull
        loops: Animation.Infinite

        on_LoopsRunChanged: {
            if (_loopsRun === 1 && pulleyMenu.userAttempt && !playButton.enabled) {
                playButton.enabled = true
            }
        }
    }

    TouchBlocker {
        id: touchBlocker
        anchors.fill: parent
    }

    Button {
        id: playButton
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge * (root._demonstrated ? 2 : 4)
            horizontalCenter: parent.horizontalCenter
        }
        color: tutorialTheme.primaryColor
        highlightColor: tutorialTheme.highlightColor
        highlightBackgroundColor: tutorialTheme.highlightBackgroundColor
        enabled: false
        text: root._demonstrated
                //% "Play again"
              ? qsTrId("tutorial-bt-play_again")
                //% "Play"
              : qsTrId("tutorial-bt-play")

        opacity: enabled ? 1 : 0
        Behavior on opacity {
            FadeAnimation {
                duration: root._demonstrated ? 400 : 1000
            }
        }

        onClicked: {
            enabled = false
            timeline3.stop()
            timeline2.restart()
            touchBlocker.enabled = true
        }

        InfoLabel {
            anchors {
                bottom: parent.top
                bottomMargin: 2 * Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            width: hintLabel.width
            visible: !root._demonstrated
            color: tutorialTheme.highlightColor
            //% "See it in action"
            text: qsTrId("tutorial-la-see_it_in_action")
        }
    }

    HintLabel {
        id: overlayLabel

        parent: __silica_applicationwindow_instance
        atBottom: true
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
        ListElement { type: 0; firstName: "Robin"; lastName: "Burchell"; time: "Tuesday" }
        ListElement { type: 1; firstName: "陈怡因"; lastName: ""; time: "Monday" }
        ListElement { type: 1; firstName: "Jaakko"; lastName: "Roppola"; time: "Monday" }
        ListElement { type: 0; firstName: "Chris"; lastName: "Adams"; time: "Monday" }
    }

    TestEvent {
        id: touchInput

        // Update position as thumb rotates
        property var pos: hand.thumb.rotation, root.mapFromItem(hand.pressCircle, hand.pressCircle.width/2, hand.pressCircle.height/2)
        property bool pressed

        function press() {
            touchBlocker.enabled = false
            mousePress(flickable, pos.x, pos.y, Qt.LeftButton, 0, -1)
            touchBlocker.enabled = true
            pressed = true
        }

        function release() {
            touchBlocker.enabled = false
            mouseRelease(flickable, pos.x, pos.y, Qt.LeftButton, 0, -1)
            touchBlocker.enabled = true
            pressed = false
        }

        function move() {
            touchBlocker.enabled = false
            mouseMove(flickable, pos.x, pos.y, -1, Qt.LeftButton)
            touchBlocker.enabled = true
        }

        onPosChanged: {
            if (pressed) {
                move()
            }
        }
    }

    Hand {
        id: hand

        handScale: 0.7
        pressRotate: -2
        pressTranslate: 6
        dragRotate: -33
        dragTranslate: 50

        // Reverse the scaling of the app, to maintain the original size
        scale: 1 / __silica_applicationwindow_instance._wallpaperItem.scale
    }

    RadialGradient {
        id: metaBackground

        parent: __silica_applicationwindow_instance
        anchors.fill: parent
        z: -1
        visible: timeline2.running

        gradient: Gradient {
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 1) }
            GradientStop { position: 0.6; color: Qt.rgba(0, 0, 0, 1) }
            GradientStop { position: 0.4; color: Qt.rgba(0.3, 0.3, 0.3, 1) }
            GradientStop { position: 0.0; color: Qt.rgba(0.3, 0.3, 0.3, 1) }
        }
    }
}
