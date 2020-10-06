/****************************************************************************************
**
** Copyright (c) 2013-2020 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.1
import QtQuick.Window 2.1 as QtQuick
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "CoverLoader.js" as CoverLoader
import "private"

Window {
    id: window

    // Provides a globally available identifier for use by components.
    property alias __silica_applicationwindow_instance: window

    property var initialPage
    property alias pageStack: stack
    property var cover: "private/DefaultCover.qml"
    property real bottomMargin
    property bool applicationActive: Qt.application.active

    // This does not change on runtime
    property bool _transpose: (screenRotation % 180) != 0
             // HACK: This fixes VKB in emulator, where currently screen rotation is fixed and
             // screen size changes when switching between portrait/landscape mode.
             || (width > height != Screen.width > Screen.height)

    property QtObject _coverWindow
    property Item _coverObject
    property bool _incubatingCoverWindow

    // parent items declared within ApplicationWindow to
    // Image element that follows page orientation
    default property alias _contentChildren: content.data
    property alias contentItem: content
    property alias indicatorParentItem: indicatorParent
    property alias _contentScale: contentScale
    property alias _clippingItem: clippingItem
    property alias _wallpaperItem: wallpaper
    readonly property real _screenWidth: stack.verticalOrientation ? Screen.width : Screen.height
    readonly property real _screenHeight: stack.verticalOrientation ? Screen.height : Screen.width
    property alias _rotatingItem: rotatingItem
    property alias _touchBlockerItem: touchBlocker
    property alias _rotating: wallpaperRotationAnim.running

    property color dimmedRegionColor: palette.highlightDimmerColor

    property bool _dimScreen: { return false }
    readonly property bool _dimmingActive: _dimScreen || dimAnimation.running

    property bool _autoGcWhenInactive: Config.wayland
    property int allowedOrientations: Orientation.All
    property int _defaultPageOrientations: Orientation.Portrait
    property int _defaultLabelFormat: Text.AutoText

    property bool _roundedCorners: true
    property bool _resizeContent: true

    property alias _overlayBackgroundSource: overlayBackgroundSource
    readonly property Item _applicationBlur: applicationBlur.blur ? applicationBlur : null

    // TODO minimization gc is temporary disabled while v4 gc does not
    // release memory allocated for js heap. See JB#22508 and JB#22814
    // Timer {
    //     id: autoGcTimer
    //     running: _autoGcWhenInactive && !Qt.application.active
    //     interval: Math.random()*15000+15000 // 15-30 seconds?
    //     onTriggered: gc()
    // }

    property QtObject __quickWindow
    onWindowChanged: {
        __quickWindow = window ? window : null
    }
    property var _coverIncubator: null
    function _loadCover() {
        if (cover && !_coverWindow) {
            if (_incubatingCoverWindow) {
                return
            }
            if (!Config.desktop) {
                var component = Qt.createComponent("private/CoverWindow.qml")
                if (component.status === Component.Ready) {
                    _coverIncubator = component.incubateObject(window)
                } else {
                    console.log("ApplicationWindow.qml failed create cover window component", component.errorString())
                }

                if (_coverIncubator.status != Component.Ready) {
                    _incubatingCoverWindow = true
                    _coverIncubator.onStatusChanged = function(status) {
                        if (status == Component.Ready) {
                            _coverWindow = _coverIncubator.object
                            _coverIncubator = null
                            _incubatingCoverWindow = false
                            _loadCover()
                        } else if (status == Component.Error) {
                            _incubatingCoverWindow = false
                        }
                    }
                    return
                }
                _coverWindow = _coverIncubator.object
            }
        }
        CoverLoader.load(cover, _coverWindow ? _coverWindow.contentItem : null,
            function(obj) {
                _coverObject = obj
                if (_coverObject !== null) {
                    // We cannot blindly assign _coverObject to _coverWindow.cover (DeclarativeCover)
                    // as the _coverObject can be an item that is not inherited from DeclarativeCover (e.g. QQuickRectangle)
                    try {
                        _coverWindow.cover = _coverObject
                    } catch (e) {
                        console.log("Warning: recommended to use Cover or CoverBackground component based cover")
                    }
                    _coverObject.visible = true
                    if (!Config.wayland) _coverObject.rotation = 0 - window.screenRotation
                    _updateCoverVisibility()
                } else if (_coverWindow) {
                    _coverWindow.destroy()
                    _coverWindow = null
                }
            })
    }

    // For page stack applications, bind orientation to the Page at the top of the stack
    _allowedOrientations: stack.currentPage ? stack.currentPage._allowedOrientations : allowedOrientations
    _pageOrientation: stack.currentPage ? stack.currentPage._windowOrientation : undefined
    _backgroundVisible: !stack.currentPage
                || !stack.currentPage._opaqueBackground
                || !stack._currentContainer
                || !stack._currentContainer.soleVisiblePage
    _backgroundColor: {
        if (stack.currentPage
                && stack._currentContainer
                && stack._currentContainer.soleVisiblePage) {
            return stack.currentPage.backgroundColor
        } else if (Config.desktop) {
            // Use black background when running Silica on desktop without ambiences
            return "black"
        } else {
            return "transparent"
        }
    }

    focus: true
    objectName: "rootWindow"

    // If we have anything assigned to cover, then we let lipstick know that a cover window may be coming.
    _haveCoverHint: !!cover

    onCoverChanged: {
        _coverObject = null
        // If cover is set to null/undefined/"" and callback given to CoverLoader.load
        // handles destroying _coverWindow.
        if ( pageStack.currentPage) {
            _loadCover()
        }
    }

    OverlayBackgroundSource {
        id: overlayBackgroundSource

        width: Screen.width
        height: Screen.height

        sourceItem: wallpaper
        backgroundItem: Wallpaper {
            width: Screen.width
            height: Screen.height
        }
    }

    BlurEffect {
        id: applicationBlur
        sourceItem: overlayBackgroundSource
        visible: false
        blur: overlayBackgroundSource.capturing

        iterations: 2
        kernel: BlurEffect.Gaussian17
//        levels: Theme.pixelRatio >= 1.5 ? 4 : 3         // Homescreen values
        levels: Theme.pixelRatio >= 1.5 ? 3 : 2
        deviation: 5
    }

    // background image
    Item {
        id: wallpaper
        width: Screen.width
        height: Screen.height
        anchors.centerIn: parent

        rotation: Config.desktop ? 0 : window.QtQuick.Screen.angleBetween(Qt.PortraitOrientation, window.QtQuick.Screen.primaryOrientation)

        ThemeTransaction {
            deferAmbience: ambienceChangeTimer.running
            onAmbienceAboutToChange: {
                if (Config.wayland && window.__quickWindow.visible) { // Don't do this inside of the compositor.
                    ambienceChangeTimer.restart()
                }
            }
        }

        Timer {
            id: ambienceChangeTimer
            interval: 600
        }

        StateGroup {
            id: ambienceChangeStates

            states: State {
                name: "Changing"
                when: ambienceChangeTimer.running

                PropertyChanges {
                    target: window.pageStack.currentPage && window.pageStack.currentPage._opaqueBackground
                            ? window.pageStack.currentPage
                            : window
                    _windowOpacity: 0
                }
            }

            transitions: [
                Transition {
                    to: "Changing"

                    NumberAnimation {
                        id: ambienceChangeFadeOut

                        property: "_windowOpacity"
                        easing.type: Easing.InOutQuad
                        duration: 400;
                        alwaysRunToEnd: true
                    }
                }, Transition {
                    from: "Changing"

                    NumberAnimation {
                        property: "_windowOpacity"
                        easing.type: Easing.InOutQuad
                        duration: 400;
                        alwaysRunToEnd: true
                    }
                }
            ]
        }

        Item {
            id: rotatingItem

            z: 1
            anchors.centerIn: parent
            width: stack.verticalOrientation ? parent.width : parent.height
            height: stack.verticalOrientation ? parent.height : parent.width
            rotation: stack.currentOrientation === Orientation.Landscape
                      ? 90
                      : stack.currentOrientation === Orientation.PortraitInverted
                        ? 180
                        : stack.currentOrientation === Orientation.LandscapeInverted
                          ? 270
                          : 0
            opacity: clippingItem.opacity

            Behavior on rotation {
                SequentialAnimation {
                    id: wallpaperRotationAnim
                    PropertyAction {}
                    PauseAnimation { duration: 200 }
                }
            }
        }

        Item {
            id: clippingItem

            z: 1
            width: parent.width - (stack.horizontalOrientation ? Math.max(window.bottomMargin, stack.panelSize) : 0)
            height: parent.height - (stack.verticalOrientation ? Math.max(window.bottomMargin, stack.panelSize) : 0)
            clip: stack.panelSize > 0

            opacity: _dimScreen ? Theme.opacityLow : 1.0
            Behavior on opacity { FadeAnimation { id: dimAnimation } }

            Item {
                id: content

                property alias _windowOpacity: content.opacity

                // Content is now being resized. We need to add a property to skip resizing if there
                // is such requirement in an app.
                anchors.fill: parent

                transform: Scale {
                    id: contentScale
                    property bool animationRunning: xAnim.running || yAnim.running
                    Behavior on xScale { NumberAnimation { id: xAnim; duration: 100 } }
                    Behavior on yScale { NumberAnimation { id: yAnim; duration: 100 } }
                }

                PageStack {
                    id: stack

                    property alias _testMode: virtualKeyboardObserver.testMode
                    property alias currentOrientation: virtualKeyboardObserver.orientation
                    property alias verticalOrientation: virtualKeyboardObserver.verticalOrientation
                    property alias horizontalOrientation: virtualKeyboardObserver.horizontalOrientation

                    property alias panelSize: virtualKeyboardObserver.panelSize
                    property alias imSize: virtualKeyboardObserver.imSize

                    clip: bottomMargin > 0
                    anchors.fill: parent
                    focus: true

                    VirtualKeyboardObserver {
                        id: virtualKeyboardObserver
                        transpose: window._transpose
                        active: window.activeFocus && window._resizeContent
                        orientation: stack.currentPage ? stack.currentPage.orientation : window.orientation
                    }
                }

                Item {
                    id: indicatorParent
                    anchors.fill: parent
                }

                TouchBlocker {
                    id: touchBlocker

                    // By default, return to disabled after any activation
                    property bool _defaultEnabled: false

                    anchors.fill: parent
                    enabled: _defaultEnabled
                }
            }

            states: [
                State {
                    when:  stack.currentOrientation == Orientation.Portrait ||
                           stack.currentOrientation == Orientation.None

                    AnchorChanges {
                        target: clippingItem
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: undefined
                        anchors.bottom: undefined
                    }
                },

                State {
                    when:  stack.currentOrientation == Orientation.PortraitInverted

                    AnchorChanges {
                        target: clippingItem
                        anchors.top: undefined
                        anchors.left: undefined
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }
                },

                State {
                    when:  stack.currentOrientation == Orientation.Landscape

                    AnchorChanges {
                        target: clippingItem
                        anchors.top: undefined
                        anchors.left: undefined
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }
                },

                State {
                    when:  stack.currentOrientation == Orientation.LandscapeInverted

                    AnchorChanges {
                        target: clippingItem
                        anchors.top: undefined
                        anchors.left: parent.left
                        anchors.right: undefined
                        anchors.bottom: parent.bottom
                    }
                }
            ]
        }
    }

    ReturnToHomeHintCounter {}

    Component.onCompleted: {
        if (initialPage) {
            if (!initialPage.createObject && (typeof initialPage !== "string")) {
                if (initialPage.parent === null) {
                    console.log('Warning: specifying an object instance for initialPage is sub-optimal - prefer to use a Component')
                }
            }
            pageStack.animatorPush(initialPage)
        }

        if (cover) {
            _loadCover()
        }
        if (Config.layoutGrid) {
            var component = Qt.createComponent(Qt.resolvedUrl("private/LayoutGrid.qml"))
            if (component.status == Component.Ready) {
                component.createObject(window)
            } else {
                console.warn("LayoutGrid.qml instantiation failed " + component.errorString())
            }
        }
    }
}
