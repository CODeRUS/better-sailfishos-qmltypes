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
import "UIConstants.js" as UI

Style {
    // Font
    property string fontFamily: UiConstants.DefaultFontFamily
    property int fontPixelSize: UI.FONT_DEFAULT_SIZE

    // Color
    property color textColor: !inverted? UI.COLOR_INVERTED_FOREGROUND : UI.COLOR_FOREGROUND

    // Background
    property url valueBackground: "image://theme/meegotouch-slider-handle-value"+__invertedString+"-background"
    property url labelArrowDown: "image://theme/meegotouch-slider-handle-label-arrow-down"+__invertedString
    property url labelArrowUp: "image://theme/meegotouch-slider-handle-label-arrow-up"+__invertedString
    property url labelArrowLeft: "image://theme/meegotouch-slider-handle-label-arrow-left"+__invertedString
    property url labelArrowRight: "image://theme/meegotouch-slider-handle-label-arrow-right"+__invertedString
    property url handleBackground: "image://theme/meegotouch-slider-handle"+__invertedString+"-background-horizontal"
    property url handleBackgroundPressed: "image://theme/meegotouch-slider-handle"+__invertedString+"-background-pressed-horizontal"
    property url grooveItemBackground: "image://theme/meegotouch-slider"+__invertedString+"-background-horizontal"
    property url grooveItemElapsedBackground: "image://theme/" + __colorString + "meegotouch-slider-elapsed"+__invertedString+"-background-horizontal"

    // Mouse
    property real mouseMarginRight: 0.0
    property real mouseMarginLeft: 0.0
    property real mouseMarginTop: 0.0
    property real mouseMarginBottom: 0.0
}
