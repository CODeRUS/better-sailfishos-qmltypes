import QtQuick 2.4
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

PinchArea {
    id: overlay

    property bool isPortrait
    property real topButtonRowHeight
    property bool showCommonControls: true // any controls from here
    property bool deviceToggleEnabled
    property bool inButtonLayout

    property alias shutter: shutterContainer.children
    property alias anchorContainer: anchorContainer
    property alias container: container
    readonly property alias settingsOpacity: row.opacity

    property bool _pinchActive
    property bool _topMenuOpen
    property bool _closing
    // top menu open or transitioning
    readonly property bool _exposed: _topMenuOpen
                || _closing
                || verticalAnimation.running
                || dragArea.drag.active

    default property alias _data: container.data

    readonly property int _captureButtonLocation: overlay.isPortrait
                ? Settings.global.portraitCaptureButtonLocation
                : Settings.global.landscapeCaptureButtonLocation

    property real _progress: (panel.y + panel.height) / panel.height

    property real _menuItemHorizontalSpacing: Screen.sizeCategory >= Screen.Large
                                              ? Theme.paddingLarge * 2
                                              : Theme.paddingLarge
    property real _headerHeight: Screen.sizeCategory >= Screen.Large
                                 ? Theme.itemSizeMedium
                                 : Theme.itemSizeSmall + Theme.paddingMedium
    property real _headerTopMargin: Screen.sizeCategory >= Screen.Large
                                    ? Theme.paddingLarge + Theme.paddingSmall
                                    : -((Theme.paddingMedium + Theme.paddingSmall) / 2) // first button reactive area overlapping slightly
    readonly property real _menuWidth: Screen.sizeCategory >= Screen.Large
                                       ? Theme.iconSizeLarge + Theme.paddingMedium*2 // increase icon hitbox
                                       : Theme.iconSizeMedium + Theme.paddingMedium + Theme.paddingSmall

    property color _highlightColor: Theme.colorScheme == Theme.LightOnDark
                                    ? Theme.highlightColor
                                    : Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark)

    property real _commonControlOpacity: showCommonControls ? 1.0 : 0.0
    Behavior on _commonControlOpacity { FadeAnimation {} }

    onShowCommonControlsChanged: {
        if (!showCommonControls) {
            closeMenus()
        }
    }

    on_CaptureButtonLocationChanged: inButtonLayout = false

    onIsPortraitChanged: {
        upperHeader.pressedMenu = null
    }

    signal clicked(var mouse)

    function closeMenus() {
        _closing = true
        whiteBalanceMenu.open = false
        _topMenuOpen = false
        inButtonLayout = false
        _closing = false
    }

    onPinchStarted: _pinchActive = true
    onPinchFinished: _pinchActive = false

    property list<Item> _buttonAnchors
    _buttonAnchors: [
        ButtonAnchor { id: buttonAnchorTL; index: 0; anchors { left: parent.left; top: parent.top } visible: !overlay.isPortrait },
        ButtonAnchor { id: buttonAnchorCL; index: 1; anchors { left: parent.left; verticalCenter: parent.verticalCenter } },
        ButtonAnchor { id: buttonAnchorBL; index: 2; anchors { left: parent.left; bottom: parent.bottom } },
        ButtonAnchor { id: buttonAnchorBC; index: 3; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } },
        ButtonAnchor { id: buttonAnchorBR; index: 4; anchors { right: parent.right; bottom: parent.bottom } },
        ButtonAnchor { id: buttonAnchorCR; index: 5; anchors { right: parent.right; verticalCenter: parent.verticalCenter } },
        ButtonAnchor { id: buttonAnchorTR; index: 6; anchors { right: parent.right; top: parent.top } visible: !overlay.isPortrait }
    ]

    // Position of other elements given the capture button position
    property var _portraitPositions: [
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorBR, "exposure": Qt.AlignRight }, // buttonAnchorTL
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorBR, "exposure": Qt.AlignRight }, // buttonAnchorCL
        { "captureMode": overlayAnchorBR, "cameraDevice": overlayAnchorBC, "exposure": Qt.AlignRight }, // buttonAnchorBL
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorBR, "exposure": Qt.AlignRight }, // buttonAnchorBC
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorBC, "exposure": Qt.AlignRight }, // buttonAnchorBR
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorBR, "exposure": Qt.AlignLeft  }, // buttonAnchorCR
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorBR, "exposure": Qt.AlignLeft  }, // buttonAnchorTR
    ]
    property var _landscapePositions: [
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorCL, "exposure": Qt.AlignRight }, // buttonAnchorTL
        { "captureMode": overlayAnchorBL, "cameraDevice": overlayAnchorTL, "exposure": Qt.AlignRight }, // buttonAnchorCL
        { "captureMode": overlayAnchorCL, "cameraDevice": overlayAnchorTL, "exposure": Qt.AlignRight }, // buttonAnchorBL
        { "captureMode": overlayAnchorBR, "cameraDevice": overlayAnchorTR, "exposure": Qt.AlignLeft  }, // buttonAnchorBC
        { "captureMode": overlayAnchorCR, "cameraDevice": overlayAnchorTR, "exposure": Qt.AlignLeft  }, // buttonAnchorBR
        { "captureMode": overlayAnchorBR, "cameraDevice": overlayAnchorTR, "exposure": Qt.AlignLeft  }, // buttonAnchorCR
        { "captureMode": overlayAnchorBR, "cameraDevice": overlayAnchorCR, "exposure": Qt.AlignLeft  }, // buttonAnchorTR
    ]

    property var _overlayPosition: overlay.isPortrait ? _portraitPositions[overlay._captureButtonLocation]
                                                      : _landscapePositions[overlay._captureButtonLocation]

    Item {
        id: shutterContainer

        parent: overlay._buttonAnchors[overlay._captureButtonLocation]
        anchors.fill: parent
    }

    ToggleButton {
        parent: _overlayPosition.cameraDevice
        anchors.centerIn: parent
        model: [ "primary", "secondary" ]
        settings: Settings
        property: "cameraDevice"
        icon: "image://theme/icon-camera-switch"
        opacity: _commonControlOpacity
        visible: opacity > 0.0 && Settings.hasMultipleCameras
        enabled: overlay.deviceToggleEnabled
    }

    CaptureModeMenu {
        id: captureModeMenu

        property real itemStep: Theme.itemSizeExtraSmall + spacing

        parent: _overlayPosition.captureMode
        anchors.verticalCenterOffset: height/2
        alignment: (parent.anchors.left == container.left ? Qt.AlignRight : Qt.AlignLeft) | Qt.AlignBottom
        open: true
        opacity: _commonControlOpacity
        visible: opacity > 0.0

        Rectangle {
            id: captureModeHighlight
            z: -1
            width: Theme.itemSizeExtraSmall
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: parent.horizontalCenter
            radius: width / 2
            color: Theme.rgba(_highlightColor, 0.4)
            opacity: y < -captureModeMenu.itemStep ? 1.0 - (captureModeMenu.itemStep + y) / (-captureModeMenu.itemStep/2)
                                                   : (y > 0 ? 1.0 - y/(captureModeMenu.itemStep/2) : 1.0)
            y: {
                var val = captureModeDragArea.dragY
                if (!captureModeDragArea.drag.active) {
                    return val
                }

                if (captureModeMenu.currentIndex == 0) {
                    if (val < -captureModeMenu.itemStep*1.5) {
                        // if drag is clearly started up or down, canceling it shouldn't require moving finger back
                        // to initial y -> enter one way mode
                        captureModeDragArea.maximumDragY = -captureModeMenu.itemStep
                        val += captureModeMenu.itemStep*2
                    } else {
                        if (val > (-0.5 * captureModeMenu.itemStep)) {
                            captureModeDragArea.minimumDragY = -captureModeMenu.itemStep
                        }
                        val = Math.min(val, 0)
                    }
                } else if (captureModeMenu.currentIndex == 1) {
                    if (val > captureModeMenu.itemStep*0.5) {
                        val -= captureModeMenu.itemStep*2
                        captureModeDragArea.minimumDragY = 0
                    } else {
                        if (val < -0.5 * captureModeMenu.itemStep) {
                            captureModeDragArea.maximumDragY = 0
                        }
                        val = Math.max(val, -captureModeMenu.itemStep)
                    }
                }
                return val
            }
            Behavior on y { id: captureModeBehavior; YAnimator { duration: 200; easing.type: Easing.OutQuad } }
        }
    }

    MouseArea {
        id: captureModeDragArea

        // dragRatio increases the multiplier how much drag has to happen compared to how much
        // the values really change.
        property real dragRatio: 2
        property real minimumDragY: -captureModeMenu.itemStep * 2
        property real maximumDragY: captureModeMenu.itemStep
        property real dragY: captureModeDragTarget.y / dragRatio

        anchors.fill: parent
        enabled: !overlay._topMenuOpen && !overlay.inButtonLayout && showCommonControls

        Item {
            id: captureModeDragTarget

            Binding on y {
                when: !captureModeDragArea.drag.active
                value: captureModeDragArea.dragRatio * (captureModeMenu.currentIndex - 1) * captureModeMenu.itemStep
            }
        }

        drag {
            target: captureModeDragTarget
            // Extend the range beyond the allowed range so that a vertical drag always
            // changes the current mode, wrapping around at the ends
            minimumY: captureModeDragArea.dragRatio * captureModeDragArea.minimumDragY
            maximumY: captureModeDragArea.dragRatio * captureModeDragArea.maximumDragY
            axis: Drag.YAxis
            filterChildren: true
            onActiveChanged: {
                captureModeBehavior.enabled = !drag.active
                if (!drag.active) {
                    var index = Math.round((captureModeHighlight.y + captureModeMenu.itemStep) / captureModeMenu.itemStep) % 2
                    captureModeMenu.selectItem(index)
                    captureModeDragArea.minimumDragY = -captureModeMenu.itemStep * 2
                    captureModeDragArea.maximumDragY = captureModeMenu.itemStep
                }
            }
        }

        MouseArea {
            id: dragArea

            property real _lastPos
            property real _direction

            anchors.fill: parent
            enabled: overlay._topMenuOpen

            drag {
                target: !overlay.inButtonLayout ? panel : undefined
                minimumY: -panel.height
                maximumY: 0
                axis: Drag.YAxis
                filterChildren: true
                onActiveChanged: {
                    if (!drag.active && panel.y < -(panel.height / 3) && _direction <= 0) {
                        overlay._topMenuOpen = false
                    } else if (!drag.active && panel.y > (-panel.height * 2 / 3) && _direction >= 0) {
                        overlay._topMenuOpen = true
                    }
                }
            }

            onPressed: {
                _direction = 0
                _lastPos = panel.y
            }
            onPositionChanged: {
                var pos = panel.y
                _direction = (_direction + pos - _lastPos) / 2
                _lastPos = panel.y
            }

            MouseArea {
                id: container

                property real pressX
                property real pressY

                anchors.fill: parent
                opacity: Math.min(1 - overlay._progress, 1 - anchorContainer.opacity)
                enabled: !overlay._pinchActive && showCommonControls

                onPressed: {
                    pressX = mouseX
                    pressY = mouseY
                }

                onClicked: {
                    if (whiteBalanceMenu.expanded) {
                        whiteBalanceMenu.open = false
                    } else if (overlay.inButtonLayout) {
                        overlay.inButtonLayout = false
                    } else {
                        overlay.clicked(mouse)
                    }
                }

                onPressAndHold: {
                    if (!overlay._topMenuOpen) {
                        var dragDistance = Math.max(Math.abs(mouseX - pressX),
                                                    Math.abs(mouseY - pressY))
                        if (dragDistance < Theme.startDragDistance) {
                            overlay.inButtonLayout = true
                        }
                    }
                }

                MouseArea {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: row.width
                    height: Theme.itemSizeLarge
                    enabled: !overlay._exposed && !overlay.inButtonLayout && showCommonControls

                    onClicked: overlay._topMenuOpen = true

                    onPressAndHold: container.pressAndHold(mouse)
                }

                OverlayAnchor { id: overlayAnchorBL; anchors { left: parent.left; bottom: parent.bottom } }
                OverlayAnchor { id: overlayAnchorBC; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } }
                OverlayAnchor { id: overlayAnchorBR; anchors { right: parent.right; bottom: parent.bottom } }
                OverlayAnchor { id: overlayAnchorCL; anchors { left: parent.left; verticalCenter: parent.verticalCenter } }
                OverlayAnchor { id: overlayAnchorCR; anchors { right: parent.right; verticalCenter: parent.verticalCenter } }
                OverlayAnchor { id: overlayAnchorTL; anchors { left: parent.left; top: parent.top } }
                OverlayAnchor { id: overlayAnchorTR; anchors { right: parent.right; top: parent.top } }
            }

            MouseArea {
                anchors.fill: parent
                enabled: overlay._exposed
                onClicked: overlay._topMenuOpen = false
            }

            Item {
                id: panel

                Binding {
                    target: panel
                    property: "y"
                    value: _topMenuOpen ? 0 : -panel.height
                    when: expandBehavior.enabled
                }
                Behavior on y {
                    id: expandBehavior
                    enabled: !dragArea.drag.active
                    NumberAnimation {
                        id: verticalAnimation
                        duration: 200; easing.type: Easing.InOutQuad
                    }
                }

                width: overlay.width
                height: Screen.width / 2
            }

            Rectangle {
                id: highlight

                anchors.fill: parent
                visible: overlay._exposed
                color: "black"
                opacity: 0.6 * (1 - container.opacity)
            }

            Row {
                id: row

                y: Math.round(height * panel.y / panel.height) + overlay._headerHeight + overlay._headerTopMargin
                anchors.horizontalCenter: parent.horizontalCenter

                height: Screen.height / 2

                opacity: 1 - container.opacity
                enabled: overlay._exposed
                visible: overlay._exposed

                spacing: overlay._menuItemHorizontalSpacing

                SettingsMenu {
                    id: timerMenu

                    width: overlay._menuWidth
                    title: Settings.timerText
                    header: upperHeader
                    model: [ 0, 3, 10, 15 ]
                    delegate: SettingsMenuItem {
                        settings: Settings.mode
                        property: "timer"
                        value: modelData
                        icon: Settings.timerIcon(modelData)
                    }
                }

                SettingsMenu {
                    id: flashMenu

                    visible: model.length > 0
                    width: overlay._menuWidth
                    title: Settings.flashText
                    header: upperHeader
                    model: Settings.mode.flashValues
                    delegate: SettingsMenuItem {
                        settings: Settings.mode
                        property: "flash"
                        value: modelData
                        icon: Settings.flashIcon(modelData)
                        iconVisible: !selected
                    }
                }

                SettingsMenu {
                    id: isoMenu

                    width: overlay._menuWidth
                    title: Settings.isoText
                    header: upperHeader
                    model: Settings.mode.isoValues
                    delegate: SettingsMenuItemBase {
                        settings: Settings.mode
                        property: "iso"
                        value: modelData

                        IsoItem {
                            anchors.centerIn: parent
                            visible: !selected
                            value: modelData
                        }
                    }
                }

                SettingsMenu {
                    id: gridMenu

                    width: overlay._menuWidth
                    title: Settings.viewfinderGridText
                    header: upperHeader
                    model: Settings.mode.viewfinderGridValues
                    delegate: SettingsMenuItem {
                        settings: Settings.mode
                        property: "viewfinderGrid"
                        value: modelData
                        icon: Settings.viewfinderGridIcon(modelData)
                    }
                }
            }

            HeaderLabel {
                id: upperHeader

                anchors { left: parent.left; bottom: row.top; right: parent.right }
                height: overlay._headerHeight
                opacity: row.opacity
            }
        }
    }

    Row {
        id: topRow

        property real _topRowMargin: overlay.topButtonRowHeight/2 - overlay._menuWidth/2

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: row.spacing
        opacity: _commonControlOpacity
        visible: opacity > 0.0

        function dragY(yValue) {
            return yValue != undefined ? Math.max(topRow._topRowMargin, row.y + yValue)
                                       : topRow._topRowMargin
        }

        Item {
            width: overlay._menuWidth
            height: width
            visible: Settings.mode.flashValues.length > 0
            y: topRow.dragY(flashMenu.currentItem.y)

            Image {
                anchors.centerIn: parent
                source: Settings.flashIcon(Settings.mode.flash) + "?" + Theme.lightPrimaryColor
            }
        }

        Item {
            width: overlay._menuWidth
            height: width
            y: topRow.dragY(isoMenu.currentItem.y)

            IsoItem {
                anchors.centerIn: parent
                value: isoMenu.currentItem.value
            }
        }
    }

    Item {
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }

        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
        opacity: !Settings.defaultSettings ? row.opacity : 0.0
        visible: overlay._exposed

        Behavior on opacity {
            enabled: overlay._exposed
            FadeAnimation {}
        }

        CameraButton {
            background.visible: false
            enabled: !Settings.defaultSettings && parent.opacity > 0.0

            icon {
                opacity: pressed ? 0.5 : 1.0
                source: "image://theme/icon-camera-reset?" + (pressed ? _highlightColor : Theme.lightPrimaryColor)
            }

            onClicked: {
                upperHeader.pressedMenu = null
                Settings.reset()
            }
        }
    }

    Column {
        x: exposureSlider.alignment == Qt.AlignLeft ? (isPortrait ? 0 : Theme.paddingLarge)
                                                    : parent.width - width - (isPortrait ? 0 : Theme.paddingLarge)
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: isPortrait ? Theme.paddingMedium : 0
        }
        spacing: Theme.paddingSmall
        opacity: _commonControlOpacity
        visible: opacity > 0.0

        WhiteBalanceMenu {
            id: whiteBalanceMenu
            anchors {
                horizontalCenter: exposureSlider.horizontalCenter
                centerIn: null
            }
            alignment: exposureSlider.alignment
            opacity: 1.0 - settingsOpacity
            spacing: Theme.paddingMedium
        }

        ExposureSlider {
            id: exposureSlider
            alignment: _overlayPosition.exposure
            enabled: !overlay._topMenuOpen && !overlay.inButtonLayout && !whiteBalanceMenu.open
            opacity: (1.0 - settingsOpacity) * (1.0 - whiteBalanceMenu.openProgress)
            height: Theme.itemSizeSmall * 5
        }
    }

    Item {
        id: anchorContainer

        anchors.fill: parent
        visible: overlay.inButtonLayout || layoutAnimation.running
        opacity: overlay.inButtonLayout ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation { id: layoutAnimation } }

        Rectangle {
            anchors.fill: parent
            opacity: 0.8
            color: "black"
        }

        Label {
            anchors {
                centerIn: parent
                verticalCenterOffset: -Theme.paddingLarge
            }
            width: overlay.isPortrait
                    ? Screen.width - (2 * Theme.itemSizeExtraLarge)
                    : Screen.width - Theme.itemSizeExtraLarge
            font.pixelSize: Theme.fontSizeExtraLarge
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            textFormat: Text.AutoText
            color: _highlightColor

            text: overlay.isPortrait
                    //% "Select location for the portrait capture key"
                    ? qsTrId("camera-la-portrait-capture-key-location")
                    //% "Select location for the landscape capture key"
                    : qsTrId("camera-la-landscape-capture-key-location")
        }
    }
}
