import QtQuick 2.2
import QtQuick.Window 2.1 as QtQuick
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

FocusScope {
    id: pannable

    property alias currentItem: content.currentItem
    property Item _pendingCurrentItem
    property real switchThreshold: Screen.width / 6

    property int orientation: QtQuick.Screen.primaryOrientation
    property int _effectiveOrientation
    onOrientationChanged: {
        if (!moving) {
            _effectiveOrientation = orientation
        }
    }

    property real _orientationAngle: QtQuick.Screen.angleBetween(
                _effectiveOrientation, QtQuick.Screen.primaryOrientation)

    property bool pan: true
    property bool panning
    readonly property bool moving: panning || _animating
    property real absoluteProgress

    property alias peekFilter: peekFilter
    property alias dragArea: dragArea
    property alias pannableItems: content.children
    property alias pannableParent: content

    readonly property bool _vertical: (_orientationAngle % 180) != 0
    readonly property bool _inverted: _orientationAngle >= 180
    property real progress
    property real _currentPos
    property real _minimumPos
    property real _maximumPos

    property bool _animating

    property real overshoot: {
        if (!currentItem) {
            return 0
        } else if ((!currentItem.leftItem && !_inverted) || (!currentItem.rightItem && _inverted)) {
            return Math.max(0, absoluteProgress)
        } else if ((!currentItem.leftItem && _inverted) || (!currentItem.rightItem && !_inverted)) {
            return -Math.min(0, absoluteProgress)
        } else {
            return 0
        }
    }
    Behavior on overshoot {
        SmoothedAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    property alias alternateItem: content.alternateItem
    property int _flickDirection: panning && _currentPos != 0
            ? (_currentPos >= 0 ? 1 : -1)
            : 0
    on_FlickDirectionChanged: { if (_flickDirection != 0) { _anchorAlternate() } }
    onPanningChanged: {
        if (panning) {
            _stopAnimation()
            panningBinding.property = _vertical ? "y" : "x"
            panningBinding.when = true
        } else {
            panningBinding.when = false

            if (alternateItem && Math.abs(_currentPos) >= switchThreshold) {
                _pendingCurrentItem = null
                currentItem = alternateItem
                _anchorAlternate()
                currentItem.visible = true
            }

            _startAnimation(Easing.OutQuad)
        }
    }

    function _startAnimation(easing) {
        if (_vertical) {
            verticalAnimation.easing.type = easing
            verticalAnimation.restart()
        } else {
            horizontalAnimation.easing.type = easing
            horizontalAnimation.restart()
        }
    }

    function _stopAnimation() {
        horizontalAnimation.stop()
        verticalAnimation.stop()
    }

    function _animationStopped() {
        if (alternateItem) {
            alternateItem.visible = false
            _clearAnchors(alternateItem)
            if (alternateItem.cleanup) {
                alternateItem.cleanup()
            }
            alternateItem = null
        }
        _effectiveOrientation = orientation
        if (_pendingCurrentItem) {
            setCurrentItem(_pendingCurrentItem, true)
        } else {
            currentItem.focus = true
        }
    }

    function _anchorAlternate() {
        if (alternateItem) {
            _clearAnchors(alternateItem)
            alternateItem.visible = alternateItem == currentItem
                    || (currentItem.leftItem == currentItem.rightItem && _currentPos != 0)
            alternateItem = null
        }
        if (_currentPos > 0 && currentItem.leftItem) {
            alternateItem = currentItem.leftItem
            _anchorToLeft(alternateItem.anchors, currentItem)
            alternateItem.visible = true
        } else if (_currentPos < 0 && currentItem.rightItem){
            alternateItem = currentItem.rightItem
            _anchorToRight(alternateItem.anchors, currentItem)
            alternateItem.visible = true
        }
    }

    function setCurrentItem(item, animate, direction) {
        if (panning) {
            return
        }
        _pendingCurrentItem = null
        if (!animate) {
            var previousItem = currentItem

            _stopAnimation()
            if (alternateItem) {
                _clearAnchors(alternateItem)
                alternateItem = null
            }
            currentItem.visible = currentItem == item
            currentItem = item
            currentItem.x = 0
            currentItem.y = 0
            currentItem.visible = true
            currentItem.focus = true

            if (previousItem && previousItem != currentItem && previousItem.cleanup) {
                previousItem.cleanup()
            }
        } else if (item == currentItem) {
            // It's on its way.
        } else if (_animating) {
            _pendingCurrentItem = item
        } else {
            if (currentItem.rightItem === item) {
                direction = "right"
            } else if (currentItem.leftItem === item) {
                direction = "left"
            }

            if (direction === "right") {
                _anchorToRight(item.anchors, currentItem)
            } else {
                _anchorToLeft(item.anchors, currentItem)
            }
            _clearAnchors(item)

            alternateItem = currentItem
            currentItem = item

            if (direction == "right") {
                _anchorToLeft(alternateItem.anchors, currentItem)
            } else {
                _anchorToRight(alternateItem.anchors, currentItem)
            }

            currentItem.visible = true
            _startAnimation(Easing.InOutQuad)
        }
    }

    function _clearAnchors(item) {
        item.anchors.left = undefined
        item.anchors.top = undefined
        item.anchors.right = undefined
        item.anchors.bottom = undefined
    }

    function _anchorToLeft(anchors, item) {
        switch (_orientationAngle) {
        case 180:
            anchors.left = item.right
            anchors.top = item.top
            break;
        case 90:
            anchors.left = item.left
            anchors.bottom = item.top
            break;
        case 270:
            anchors.left = item.left
            anchors.top = item.bottom
            break;
        default:
            anchors.top = item.top
            anchors.right = item.left
        }
    }

    function _anchorToRight(anchors, item) {
        switch (_orientationAngle) {
        case 180:
            anchors.top = item.top
            anchors.right = item.left
            break;
        case 90:
            anchors.left = item.left
            anchors.top = item.bottom
            break;
        case 270:
            anchors.left = item.left
            anchors.bottom = item.top
            break;
        default:
            anchors.left = item.right
            anchors.top = item.top
        }
    }

    Binding {
        id: panningBinding
        target: pannable.currentItem
        when: false
        property: "x"
        value: Math.max(pannable._minimumPos, Math.min(pannable.absoluteProgress, pannable._maximumPos))
    }

    NumberAnimation {
        id: horizontalAnimation
        target: pannable.currentItem
        properties: "x"
        duration: 300
        to: 0
        running: false
        easing.type: Easing.OutQuad

        onStarted: pannable._animating = true
        onStopped: {
            pannable._animating = verticalAnimation.running
            pannable._animationStopped()
        }
    }

    NumberAnimation {
        id: verticalAnimation
        target: pannable.currentItem
        properties: "y"
        duration: 300
        to: 0
        running: false
        easing.type: Easing.OutQuad

        onStarted: pannable._animating = true
        onStopped: {
            pannable._animating = horizontalAnimation.running
            pannable._animationStopped()
        }
    }

    PeekFilter {
        id: peekFilter

        leftEnabled: true
        rightEnabled: true
        objectName: "pannablePeekFilter"

        states: [
            State {
                name: "portrait"
                when: pannable._orientationAngle == 0
                PropertyChanges {
                    target: pannable
                    _currentPos: pannable.currentItem.x
                    _minimumPos: pannable.currentItem.rightItem ? -pannable.width : 0
                    _maximumPos: pannable.currentItem.leftItem ? pannable.width : 0
                    progress: Math.abs(pannable._currentPos / pannable.width)
                }
            }, State {
                name: "portrait-inverted"
                when: pannable._orientationAngle == 180
                PropertyChanges {
                    target: pannable
                    _currentPos: -pannable.currentItem.x
                    _minimumPos: pannable.currentItem.leftItem ? -pannable.width : 0
                    _maximumPos: pannable.currentItem.rightItem ? pannable.width : 0
                    progress: Math.abs(pannable._currentPos / pannable.width)
                }
            }, State {
                name: "landscape"
                when: pannable._orientationAngle == 90
                PropertyChanges {
                    target: pannable
                    _currentPos: pannable.currentItem.y
                    _minimumPos: pannable.currentItem.rightItem ? -pannable.currentItem.height : 0
                    _maximumPos: pannable.currentItem.leftItem
                                 ? Math.min(pannable.currentItem.leftItem.height, pannable.height) : 0
                    progress: Math.abs(pannable._currentPos / pannable.height)
                }
            }, State {
                name: "landscape-inverted"
                when: pannable._orientationAngle == 270
                PropertyChanges {
                    target: pannable
                    _currentPos: -pannable.currentItem.y
                    _minimumPos: pannable.currentItem.leftItem ? -pannable.currentItem.height : 0
                    _maximumPos: pannable.currentItem.rightItem
                                 ? Math.min(pannable.currentItem.rightItem.height, pannable.height) : 0
                    progress: Math.abs(pannable._currentPos / pannable.height)
                }
            }
        ]
    }

    MouseArea {
        id: dragArea

        anchors.fill: parent
        objectName: "Pannable_dragArea"

        drag {
            target: enabled ? dragTarget : null
            filterChildren: true
            axis: pannable._vertical ? Drag.YAxis : Drag.XAxis
            minimumX: -pannable.width
            maximumX: pannable.width
            minimumY: -pannable.height
            maximumY: pannable.height
            threshold: QtQuick.Screen.pixelDensity * 5 // 5mm
        }

        states: [
            State {
                name: "drag-horizontal"
                when: dragArea.drag.active && !pannable._vertical
                PropertyChanges {
                    target: pannable
                    absoluteProgress: dragTarget.x
                }
            }, State {
                name: "drag-vertical"
                when: dragArea.drag.active && pannable._vertical
                PropertyChanges {
                    target: pannable
                    absoluteProgress: dragTarget.y
                }
            }, State {
                name: "leftPeek"
                when: (peekFilter.leftActive && !pannable._inverted)
                            || (peekFilter.rightActive && pannable._inverted)
                PropertyChanges {
                    target: pannable
                    absoluteProgress: peekFilter.absoluteProgress
                }
            }, State {
                name: "rightPeek"
                when: (peekFilter.leftActive && pannable._inverted)
                            || (peekFilter.rightActive && !pannable._inverted)
                PropertyChanges {
                    target: pannable
                    absoluteProgress: -peekFilter.absoluteProgress
                }
            }
        ]

        transitions: [
            Transition {
                to: ""
                SequentialAnimation {
                    PropertyAction { target: pannable; property: "panning"; value: false }
                    PropertyAction { target: pannable; property: "absoluteProgress" }
                    PropertyAction { target: dragTarget; property: "x"; value: 0 }
                    PropertyAction { target: dragTarget; property: "y"; value: 0 }
                }
            }, Transition {
                from: ""
                SequentialAnimation {
                    PropertyAction { target: pannable; property: "absoluteProgress" }
                    PropertyAction { target: pannable; property: "panning"; value: pannable.pan }
                }
            }
        ]

        MouseArea {
            id: content
            anchors.fill: parent
            objectName: "Pannable_dragAreaContentItem"

            property Item currentItem
            property Item alternateItem
        }

        Item {
            id: dragTarget
        }
    }
}
