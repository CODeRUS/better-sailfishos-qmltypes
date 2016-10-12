/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
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

/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private

MouseArea {
    id: page

    // The status of the page. One of the following:
    //      PageStatus.Inactive - the page is not visible
    //      PageStatus.Activating - the page is transitioning into becoming the active page
    //      PageStatus.Active - the page is the current active page
    //      PageStatus.Deactivating - the page is transitioning into becoming inactive
    property int status: PageStatus.Inactive

    property bool backNavigation: true
    property bool showNavigationIndicator: true
    property bool forwardNavigation: _belowTop
    property bool canNavigateForward: forwardNavigation
    property Item pageContainer

    property int allowedOrientations: __silica_applicationwindow_instance._defaultPageOrientations
    property int orientation: Orientation.Portrait

    property alias orientationTransitions: orientationState.transitions
    property alias defaultOrientationTransition: orientationState.defaultTransition
    property bool orientationTransitionRunning

    property bool isPortrait: (orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted || orientation === Orientation.None)
    property bool isLandscape: (orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted)

    property int _navigation: PageNavigation.None
    property int _navigationPending: PageNavigation.None
    property int _wallpaperOrientation: Orientation.Portrait

    property int _allowedOrientations: {
        var allowed = allowedOrientations & __silica_applicationwindow_instance.allowedOrientations
        if (!allowed) {
            // No common supported orientations, let the page decide
            allowed = allowedOrientations
        }
        return allowed
    }
    property alias _windowOrientation: orientationState.pageOrientation

    property int _horizontalDimension: (pageContainer && _exposed && parent) ? parent.width : Screen.width
    property int _verticalDimension: (pageContainer && _exposed && parent) ? parent.height : Screen.height

    property var _forwardDestination
    property var _forwardDestinationProperties
    property int _forwardDestinationAction: PageStackAction.Push
    property Item _forwardDestinationInstance
    property var _forwardDestinationReplaceTarget
    property int _depth: parent && parent.hasOwnProperty("pageStackIndex") ? parent.pageStackIndex : -1

    property bool _exposed
    property bool _belowTop
    property bool _defaultTransition
    property bool _clickablePageIndicators: true

    property int __silica_page

    visible: false
    // This unusual binding avoids a warning when the page is destroyed.
    anchors.centerIn: page ? parent : null

    width: isPortrait ? _horizontalDimension : _verticalDimension
    height: isPortrait ? _verticalDimension : _horizontalDimension

    Binding on orientation {
        when: !orientationTransitionRunning && !blocker.running
        value: orientationState.pageOrientation
    }

    Binding on width {
        when: _defaultTransition || (!orientationTransitionRunning && !blocker.running)
        value: isPortrait ? _horizontalDimension : _verticalDimension
    }

    Binding on height {
        when: _defaultTransition || (!orientationTransitionRunning && !blocker.running)
        value: isPortrait ? _verticalDimension : _horizontalDimension
    }

    Binding on rotation {
        when: !orientationTransitionRunning && !blocker.running
        value: orientation === Orientation.Landscape
               ? 90
               : orientation === Orientation.PortraitInverted
                 ? 180
                 : orientation === Orientation.LandscapeInverted
                   ? 270
                   : 0
    }

    Timer {
        // this is needed because the transition starts asynchronously
        id: blocker
        interval: 1
    }

    Item {
        id: orientationState

        property bool completed
        // Choose the orientation this page will have given the current device orientation
        property int pageOrientation: Orientation.None
        property int desiredPageOrientation: __silica_applicationwindow_instance._selectOrientation(page._allowedOrientations, __silica_applicationwindow_instance.deviceOrientation)
        property bool desiredPageOrientationSuitable: desiredPageOrientation & __silica_applicationwindow_instance.deviceOrientation

        onDesiredPageOrientationChanged: _updatePageOrientation()
        onDesiredPageOrientationSuitableChanged: _updatePageOrientation()

        function _updatePageOrientation() {
            if (pageOrientation !== desiredPageOrientation) {
                blocker.restart()
                _defaultTransition = (transitions.length === 1 && transitions[0] === defaultTransition)
                pageOrientation = desiredPageOrientation
            }
        }

        state: 'Unanimated'
        states: [
            State {
                name: 'Unanimated'
                when: !page.pageContainer || !page._exposed || !completed
            },
            State {
                name: 'Portrait'
                when: orientationState.pageOrientation === Orientation.Portrait ||
                      orientationState.pageOrientation ===  Orientation.None
                PropertyChanges {
                    target: page
                    explicit: true
                    restoreEntryValues: false
                    width: _horizontalDimension
                    height: _verticalDimension
                    rotation: 0
                    orientation: Orientation.Portrait
                    _wallpaperOrientation: Orientation.Portrait
                }
            },
            State {
                name: 'Landscape'
                when: orientationState.pageOrientation === Orientation.Landscape
                PropertyChanges {
                    target: page
                    explicit: true
                    restoreEntryValues: false
                    width: _verticalDimension
                    height: _horizontalDimension
                    rotation: 90
                    orientation: Orientation.Landscape
                    _wallpaperOrientation: Orientation.Landscape
                }
            },
            State {
                name: 'PortraitInverted'
                when: orientationState.pageOrientation === Orientation.PortraitInverted
                PropertyChanges {
                    target: page
                    explicit: true
                    restoreEntryValues: false
                    width: _horizontalDimension
                    height: _verticalDimension
                    rotation: 180
                    orientation: Orientation.PortraitInverted
                    _wallpaperOrientation: Orientation.PortraitInverted
                }
            },
            State {
                name: 'LandscapeInverted'
                when: orientationState.pageOrientation === Orientation.LandscapeInverted
                PropertyChanges {
                    target: page
                    explicit: true
                    restoreEntryValues: false
                    width: _verticalDimension
                    height: _horizontalDimension
                    rotation: 270
                    orientation: Orientation.LandscapeInverted
                    _wallpaperOrientation: Orientation.LandscapeInverted
                }
            }
        ]

        property Transition defaultTransition: Private.PageOrientationTransition {
            targetPage: page
        }

        Component.onCompleted: {
            if (transitions.length === 0) {
                transitions = [ defaultTransition ]
            }
        }
    }

    Component.onCompleted: {
        orientationState.completed = true
        page.orientation = orientationState.pageOrientation
    }
}
