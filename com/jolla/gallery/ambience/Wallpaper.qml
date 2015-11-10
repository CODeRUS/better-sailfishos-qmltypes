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

Item {
    id: wallpaper

    property alias source: wallpaperTextureImage.source
    property real windowRotation
    property int verticalOffset
    property int horizontalOffset
    property alias ratio: wallpaperEffect.screenRatio

    property bool dimmed
    property color dimmedRegionColor: Theme.highlightDimmerColor

    property real _dimOpacity: dimmed ? 0.5 : 0.0
    Behavior on _dimOpacity { FadeAnimation { id: dimAnim; property: "_dimOpacity" } }

    Item {
        id: glassTextureItem
        visible: false
        width: glassTextureImage.width
        height: glassTextureImage.height
        Image {
            id: glassTextureImage
            opacity: 0.1
            source: "image://theme/graphic-shader-texture"
            Behavior on opacity { FadeAnimation { duration: 200 } }
        }
    }

    Image {
        id: wallpaperTextureImage
        visible: false
        source: Theme.backgroundImage
        onSourceChanged: {
            // Workaround -- seems to be necessary for the ShaderEffect to update the texture
            wallpaperEffect.wallpaperTexture = null
            wallpaperEffect.wallpaperTexture = wallpaperTextureImage
        }
    }

    ShaderEffect {
        id: wallpaperEffect
        anchors.fill: parent

        visible: wallpaperTextureImage.source != ""

        // wallpaper orientation
        readonly property bool isPortrait: (Math.floor(wallpaper.windowRotation / 90) % 2) == 0
        readonly property bool isLegacy: wallpaperTextureImage.width !== wallpaperTextureImage.height
        readonly property real screenRatio: Screen.width / Screen.height
        readonly property size normalizedSize: isLegacy
                ? (isPortrait ? Qt.size(1, 1) : Qt.size(1, screenRatio))
                : (isPortrait ? Qt.size(1 - screenRatio, 1) : Qt.size(1, (1  / screenRatio) - 1))
        readonly property point offset: Qt.point(
                (wallpaper.horizontalOffset * normalizedSize.width / Screen.height) + ((1 - normalizedSize.width) / 2),
                (wallpaper.verticalOffset * normalizedSize.height / Screen.height) + ((1 - normalizedSize.height) / 2))
        readonly property size dimensions: Qt.size(
                    wallpaper.width * normalizedSize.width / (isPortrait ? Screen.width : Screen.height),
                    wallpaper.height * normalizedSize.height / Screen.height)
        // glass texture size
        property size glassTextureSizeInv: Qt.size(1.0/(glassTextureImage.sourceSize.width),
                                                   -1.0/(glassTextureImage.sourceSize.height))

        property Image wallpaperTexture: wallpaperTextureImage
        property variant glassTexture: ShaderEffectSource {
            hideSource: true
            sourceItem: glassTextureItem
            wrapMode: ShaderEffectSource.Repeat
        }

        property color dimmedColor: Theme.rgba(dimmedRegionColor, _dimOpacity)

        // Enable blending in compositor (for events view etc..)
        blending: !Config.wayland

        vertexShader: "
           uniform highp vec2 dimensions;
           uniform highp vec2 offset;
           uniform highp mat4 qt_Matrix;
           attribute highp vec4 qt_Vertex;
           attribute highp vec2 qt_MultiTexCoord0;
           varying highp vec2 qt_TexCoord0;

           void main() {
              qt_TexCoord0 = qt_MultiTexCoord0 * dimensions + offset;
              gl_Position = qt_Matrix * qt_Vertex;
           }
        "

        fragmentShader: "
           uniform sampler2D wallpaperTexture;
           uniform sampler2D glassTexture;
           uniform highp vec2 glassTextureSizeInv;
           uniform lowp float qt_Opacity;
           uniform lowp vec4 dimmedColor;
           varying highp vec2 qt_TexCoord0;

           void main() {
              lowp vec4 wp = texture2D(wallpaperTexture, qt_TexCoord0);
              lowp vec4 tx = texture2D(glassTexture, gl_FragCoord.xy * glassTextureSizeInv);
              gl_FragColor = gl_FragColor = "
                + (dimmed || dimAnim.running ? "vec4(mix(0.4*wp.rgb + tx.rgb, dimmedColor.rgb, dimmedColor.a), 1.0)"
                                             : "vec4(0.4*wp.rgb + tx.rgb, 1.0)") + (blending ? "*qt_Opacity" : "")
                + ";
           }
        "
    }
}
