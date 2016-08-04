/****************************************************************************************
**
** Copyright (C) 2015-2016 Jolla Ltd.
** Contact: Martin Jones <martin.jones@jolla.com>
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
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
import Sailfish.Silica 1.0

Rectangle {
    color: Theme.rgba(Theme.highlightDimmerColor, 1.0)

    Item {
        id: noiseImage
        layer.enabled: true
        layer.wrapMode: ShaderEffectSource.Repeat
        visible: false
        width: noiseImageItem.width
        height: noiseImageItem.height

        Image {
            id: noiseImageItem
            source: "noise.png"
            opacity: 0.03
        }
    }

    Item {
        id: glassImage
        layer.enabled: true
        layer.wrapMode: ShaderEffectSource.Repeat
        visible: false
        width: glassImageItem.width
        height: glassImageItem.height

        Image {
            id: glassImageItem
            source: "image://theme/graphic-shader-texture"
            opacity: 0.1
        }
    }

    ShaderEffect {
        property color colorTop: Theme.rgba(Theme.highlightBackgroundColor, .15)
        property color colorBottom: Theme.rgba(Theme.highlightBackgroundColor, .3)
        property var noise: noiseImage
        property var noiseScale: Qt.size(width / noiseImage.width, height / noiseImage.height)
        property var glass: glassImage

        // glass texture size
        property size glassScale: Qt.size(width  / glassImage.width,
                                          height / glassImage.height)

        anchors.fill: parent
        vertexShader: "
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;

            uniform highp mat4 qt_Matrix;
            uniform highp vec2 noiseScale;
            uniform highp vec2 glassScale;
            uniform lowp vec4 colorTop;
            uniform lowp vec4 colorBottom;

            varying highp vec2 ntc;
            varying highp vec2 gtc;
            varying lowp vec4 color;

            void main() {
                gl_Position = qt_Matrix * qt_Vertex;
                ntc = qt_MultiTexCoord0 * noiseScale;
                gtc = qt_MultiTexCoord0 * glassScale;
                color = mix(colorTop, colorBottom, qt_MultiTexCoord0.y);
            }
        "

        fragmentShader: "

            uniform lowp sampler2D noise;
            uniform lowp sampler2D glass;
            uniform lowp float qt_Opacity;

            varying highp vec2 ntc;
            varying highp vec2 gtc;
            varying lowp vec4 color;

            void main() {
                gl_FragColor = (color + texture2D(noise, ntc) + texture2D(glass, gtc)) * qt_Opacity;
            }
        "
    }
}
