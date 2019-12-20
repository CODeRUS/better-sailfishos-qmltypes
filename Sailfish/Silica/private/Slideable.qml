import QtQuick 2.2
import QtQuick.Window 2.1 as QtQuick
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private

Private.SlideableBase {
    id: container

    property Item _pendingCurrentItem
    property real switchThreshold: Screen.width / 6

    property bool pan: true
    property bool panning
    readonly property bool moving: panning || _animating
    property real absoluteProgress

    // Pannable compatibilty
    property alias dragArea: dragArea
    property alias pannableItems: content.children
    property alias pannableParent: content

    property alias contentItem: content

    readonly property bool _vertical: (flow % 180) != 0
    readonly property bool _inverted: flow >= 180
    property real progress
    property real _currentPos
    property real _minimumPos
    property real _maximumPos

    property bool _animating

    signal movementEnded()

    property real overshoot: {
        if (!currentItem) {
            return 0
        } else if ((currentItem.Private.Slide.isLast && !_inverted)
                || (currentItem.Private.Slide.isFirst && _inverted)) {
            return Math.max(0, absoluteProgress)
        } else if ((currentItem.Private.Slide.isLast && _inverted)
                || (currentItem.Private.Slide.isFirst && !_inverted)) {
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

    property int _flickDirection: panning && _currentPos != 0
            ? (_currentPos < 0 ? Private.Slide.Forward : Private.Slide.Backward)
            : 0
    on_FlickDirectionChanged: {
        if (_flickDirection !== Private.Slide.NoDirection) {
            _anchorAlternate()
        }
    }

    onPanningChanged: {
        if (panning) {
            _stopAnimation()
            panningBinding.property = _vertical ? "y" : "x"
            panningBinding.when = true
        } else {
            panningBinding.when = false

            if (_alternateItem && Math.abs(_currentPos) >= switchThreshold) {
                _pendingCurrentItem = null
                currentItem = _alternateItem
                _anchorAlternate()
                currentItem.visible = true
            }

            _startAnimation(Easing.OutQuad)
        }
    }

    function _startAnimation(easing) {
        if (_vertical) {
            currentItemVerticalAnimation.easing.type = easing
            currentItemVerticalAnimation.from = currentItem.y

            alternateItemVerticalAnimation.to = currentItem.y > 0 ? -height : height
            alternateItemVerticalAnimation.from = alternateItem
                    ? alternateItem.y
                    : alternateItemVerticalAnimation.to

            verticalAnimation.restart()
        } else {
            currentItemHorizontalAnimation.easing.type = easing
            currentItemHorizontalAnimation.from = currentItem.x

            alternateItemHorizontalAnimation.to = currentItem.x > 0 ? -width : width
            alternateItemHorizontalAnimation.from =  alternateItem
                    ? alternateItem.x
                    : alternateItemHorizontalAnimation.to

            horizontalAnimation.restart()
        }
    }

    function _stopAnimation() {
        horizontalAnimation.stop()
        verticalAnimation.stop()
    }

    function _animationStopped() {
        if (_alternateItem) {
            _alternateItem.visible = false
            _clearAnchors(_alternateItem)
            _alternateItem.Private.Slide.cleanup()
            _alternateItem = null
        }
        movementEnded()
        if (_pendingCurrentItem) {
            setCurrentItem(_pendingCurrentItem, true)
        } else if (currentItem) {
            currentItem.focus = true
        }
    }

    function _anchorAlternate() {
        if (_alternateItem) {
            _clearAnchors(_alternateItem)
            _alternateItem.visible = _alternateItem === currentItem
                    || (currentItem.Private.Slide.forward === currentItem.Private.Slide.backward && _currentPos != 0)
            _alternateItem = null
        }
        if (_currentPos < 0) {
            if (!currentItem.Private.Slide.forward && !currentItem.Private.Slide.isLast) {
                createAdjacentItem(currentItem, Private.Slide.Forward)
            }

            if (currentItem.Private.Slide.forward) {
                _alternateItem = currentItem.Private.Slide.forward
                _anchorToForwardSide(_alternateItem.anchors, currentItem)
                _alternateItem.visible = true
            }
        } else if (_currentPos > 0) {
            if (!currentItem.Private.Slide.backward && !currentItem.Private.Slide.isFirst) {
                createAdjacentItem(currentItem, Private.Slide.Backward)
            }

            if (currentItem.Private.Slide.backward){
                _alternateItem = currentItem.Private.Slide.backward
                _anchorToBackwardSide(_alternateItem.anchors, currentItem)
                _alternateItem.visible = true
            }
        }
    }

    function setCurrentItem(item, animate, direction) {
        if (panning) {
            return
        }
        _pendingCurrentItem = null
        if (!animate || !currentItem) {
            var previousItem = currentItem

            _stopAnimation()
            if (_alternateItem) {
                _clearAnchors(_alternateItem)
                _alternateItem = null
            }
            if (currentItem) {
                currentItem.visible = currentItem === item
            }
            currentItem = item
            currentItem.x = 0
            currentItem.y = 0
            currentItem.visible = true
            currentItem.focus = true

            if (previousItem && previousItem !== currentItem) {
                previousItem.Private.Slide.cleanup()
            }
        } else if (item === currentItem) {
            // It's on its way.
        } else if (_animating) {
            _pendingCurrentItem = item
        } else {
            if (direction === Private.Slide.Forward || direction === Private.Slide.Backward) {
                // Respect the supplied value.
            } else if (direction === "left") { // Pannable compatibility
                direction = Private.Slide.Backward
            } else if (direction === "right") {
                direction = Private.Slide.Forward
            } else if (currentItem.Private.Slide.backward === item) {
                direction = Private.Slide.Backward
            } else if (currentItem.Private.Slide.forward === item) {
                direction = Private.Slide.Forward
            }

            // Establish the position the new current item will animate from by anchoring it to the
            // outgoing current item.
            if (direction === Private.Slide.Backward) {
                _anchorToForwardSide(item.anchors, currentItem)
            } else {
                _anchorToBackwardSide(item.anchors, currentItem)
            }
            _clearAnchors(item)

            _alternateItem = currentItem
            currentItem = item

            if (direction === Private.Slide.Backward) {
                _anchorToBackwardSide(_alternateItem.anchors, currentItem)
            } else {
                _anchorToForwardSide(_alternateItem.anchors, currentItem)
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

    function _anchorToBackwardSide(anchors, item) {
        switch (flow) {
        case Private.Slide.RightToLeft:
            anchors.left = item.right
            anchors.top = item.top
            break;
        case Private.Slide.TopToBottom:
            anchors.left = item.left
            anchors.bottom = item.top
            break;
        case Private.Slide.BottomToTop:
            anchors.left = item.left
            anchors.top = item.bottom
            break;
        default:
            anchors.top = item.top
            anchors.right = item.left
        }
    }

    function _anchorToForwardSide(anchors, item) {
        switch (flow) {
        case Private.Slide.RightToLeft:
            anchors.top = item.top
            anchors.right = item.left
            break;
        case Private.Slide.TopToBottom:
            anchors.left = item.left
            anchors.top = item.bottom
            break;
        case Private.Slide.BottomToTop:
            anchors.left = item.left
            anchors.bottom = item.top
            break;
        default:
            anchors.left = item.right
            anchors.top = item.top
        }
    }

    function _adjacentHeight(item) {
        return item && item.height < height ? item.height : height
    }

    Binding {
        id: panningBinding
        target: container.currentItem
        when: false
        property: "x"
        value: Math.max(container._minimumPos, Math.min(container.absoluteProgress, container._maximumPos))
    }

    ParallelAnimation {
        id: horizontalAnimation
        running: false

        onStarted: container._animating = true
        onStopped: {
            container._animating = verticalAnimation.running
            container._animationStopped()
        }

        NumberAnimation {
            id: currentItemHorizontalAnimation

            target: container.currentItem
            property: "x"
            duration: 300
            to: 0
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            id: alternateItemHorizontalAnimation

            target: container.alternateItem
            property: "x"
            duration: 300
            to: 0
            easing.type: currentItemHorizontalAnimation.easing.type
        }
    }

    ParallelAnimation {
        id: verticalAnimation

        running: false

        onStarted: container._animating = true
        onStopped: {
            container._animating = horizontalAnimation.running
            container._animationStopped()
        }

        NumberAnimation {
            id: currentItemVerticalAnimation

            target: container.currentItem
            property: "y"
            duration: 300
            to: 0
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            id: alternateItemVerticalAnimation

            target: container.alternateItem
            property: "y"
            duration: 300
            to: 0
            easing.type: currentItemVerticalAnimation.easing.type
        }
    }

    MouseArea {
        id: dragArea

        anchors.fill: parent
        objectName: "Pannable_dragArea"

        drag {
            target: enabled ? dragTarget : null
            filterChildren: true
            axis: container._vertical ? Drag.YAxis : Drag.XAxis
            minimumX: -container.width
            maximumX: container.width
            minimumY: -container.height
            maximumY: container.height
            threshold: QtQuick.Screen.pixelDensity * 5 // 5mm
        }

        states: [
            State {
                name: "drag-horizontal"
                when: dragArea.drag.active && !container._vertical
                PropertyChanges {
                    target: container
                    absoluteProgress: dragTarget.x
                }
            }, State {
                name: "drag-vertical"
                when: dragArea.drag.active && container._vertical
                PropertyChanges {
                    target: container
                    absoluteProgress: dragTarget.y
                }
            }
        ]

        transitions: [
            Transition {
                to: ""
                SequentialAnimation {
                    PropertyAction { target: container; property: "panning"; value: false }
                    PropertyAction { target: container; property: "absoluteProgress" }
                    PropertyAction { target: dragTarget; property: "x"; value: 0 }
                    PropertyAction { target: dragTarget; property: "y"; value: 0 }
                }
            }, Transition {
                from: ""
                SequentialAnimation {
                    PropertyAction { target: container; property: "absoluteProgress" }
                    PropertyAction { target: container; property: "panning"; value: container.pan }
                }
            }
        ]

        MouseArea {
            id: content
            anchors.fill: parent
            objectName: "Pannable_dragAreaContentItem"
        }

        Item {
            id: dragTarget

            states: [
                State {
                    when: !container.currentItem
                }, State {
                    name: "left-to-right"
                    when: container.flow === Private.Slide.LeftToRight
                    PropertyChanges {
                        target: container
                        _currentPos: container.currentItem.Private.Slide.offset
                        _minimumPos: !container.currentItem.Private.Slide.isLast
                                    ? -container.width
                                    : 0
                        _maximumPos: !container.currentItem.Private.Slide.isFirst
                                    ? container.width
                                    : 0
                        progress: Math.abs(container._currentPos / container.width)
                    }
                }, State {
                    name: "right-to-left"
                    when: container.flow === Private.Slide.RightToLeft
                    PropertyChanges {
                        target: container
                        _currentPos: -container.currentItem.Private.Slide.offset
                        _minimumPos: !container.currentItem.Private.Slide.isFirst
                                    ? -container.width
                                    : 0
                        _maximumPos: !container.currentItem.Private.Slide.isLast
                                    ? container.width
                                    : 0
                        progress: Math.abs(container._currentPos / container.width)
                    }
                }, State {
                    name: "top-to-bottom"
                    when: container.flow === Private.Slide.TopToBottom
                    PropertyChanges {
                        target: container
                        _currentPos: container.currentItem.Private.Slide.offset
                        _minimumPos: !container.currentItem.Private.Slide.isLast
                                     ? -container.currentItem.height
                                     : 0
                        _maximumPos: !container.currentItem.Private.Slide.isFirst
                                    ? container._adjacentHeight(container.currentItem.Private.Slide.forward)
                                    : 0
                        progress: Math.abs(container._currentPos / container.height)
                    }
                }, State {
                    name: "bottom-to-top"
                    when: container.flow === Private.Slide.BottomToTop
                    PropertyChanges {
                        target: container
                        _currentPos: -container.currentItem.Private.Slide.offset
                        _minimumPos: !container.currentItem.Private.Slide.isFirst
                                    ? -container.currentItem.height
                                    : 0
                        _maximumPos: !container.currentItem.Private.Slide.isLast
                                    ? container._adjacentHeight(container.currentItem.Private.Slide.backward)
                                    : 0
                        progress: Math.abs(container._currentPos / container.height)
                    }
                }
            ]
        }
    }
}
