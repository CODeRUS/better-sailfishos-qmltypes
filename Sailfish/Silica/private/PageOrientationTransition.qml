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

import QtQuick 2.2
import Sailfish.Silica 1.0

Transition {
    id: transition

    property alias targetPage: propertyAction.target
    property alias fadeTarget: fadeOutAnimation.target
    property alias fadeProperty: fadeOutAnimation.property
    property alias orientationChangeActions: orientationChangeActionsContainer.animations

    to: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
    from: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'

    SequentialAnimation {
        PropertyAction {
            id: propertyAction
            property: 'orientationTransitionRunning'
            value: true
        }
        NumberAnimation {
            id: fadeOutAnimation
            target: {
                if (targetPage._opaqueBackground) {
                    return targetPage
                } else if (__silica_applicationwindow_instance._backgroundVisible) {
                    return  __silica_applicationwindow_instance
                } else {
                    return  __silica_applicationwindow_instance.contentItem
                }
            }
            property: '_windowOpacity'
            easing.type: Easing.InOutQuad
            to: 0
            duration: 150
        }
        PropertyAction {
            properties: 'width,height,rotation,orientation'
        }
        SequentialAnimation {
            id: orientationChangeActionsContainer
        }
        NumberAnimation {
            target: fadeOutAnimation.target
            property: fadeOutAnimation.property
            easing.type: Easing.InOutQuad
            to: 1
            duration: 150
        }
        PropertyAction {
            target: propertyAction.target
            property: 'orientationTransitionRunning'
            value: false
        }
    }

    Component.onCompleted: {
        if (!targetPage) {
            console.warn("PageOrientationTransition: target property is missing")
        }
    }
}
