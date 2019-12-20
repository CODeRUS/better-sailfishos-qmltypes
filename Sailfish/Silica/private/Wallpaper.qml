/****************************************************************************************
**
** Copyright (C) 2014 Jolla Ltd.
** Contact: Joona Petrell <joona.petrell@jollamobile.com>
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
import QtQuick.Window 2.1
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0

GlassBackgroundBase {
    id: wallpaper

    property alias source: wallpaperTextureImage.source
    property real windowRotation
    property alias asynchronous: wallpaperTextureImage.asynchronous
    property alias status: wallpaperTextureImage.status

    property bool glassOnly

    color: Theme._wallpaperOverlayColor

    visible: wallpaperTextureImage.status === Image.Ready || glassOnly

    // wallpaper orientation
    contentAngle: Math.floor(windowRotation / 90) * 90

    patternItem: glassTextureImage
    backgroundItem: wallpaperTextureImage

    blending: !__silica_applicationwindow_instance._dimmingActive

    fillMode: GlassBackgroundBase.PreserveAspectSquare

    Image {
        id: glassTextureImage
        visible: false
        source: "image://theme/graphic-shader-texture"
    }

    Image {
        id: wallpaperTextureImage
        visible: false
        source: Theme.backgroundImage
    }
}
