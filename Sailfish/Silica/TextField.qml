/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
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

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "private"

TextBase {
    id: textField

    property alias text: preeditText.text
    property alias textWidth: textInput.width
    property alias readOnly: textInput.readOnly
    property alias inputMethodHints: textInput.inputMethodHints
    property alias inputMethodComposing: textInput.inputMethodComposing
    property alias validator: textInput.validator
    property alias echoMode: textInput.echoMode
    property alias cursorPosition: textInput.cursorPosition
    property alias selectedText: textInput.selectedText
    property alias selectionStart: textInput.selectionStart
    property alias selectionEnd: textInput.selectionEnd
    property alias acceptableInput: textInput.acceptableInput
    property alias passwordCharacter: textInput.passwordCharacter
    property alias passwordMaskDelay: textInput.passwordMaskDelay
    property alias maximumLength: textInput.maximumLength
    property alias length: textInput.length

    property real _minimumWidth: textField.width - Theme.paddingSmall - textField.textLeftMargin - textField.textRightMargin

    onHorizontalAlignmentChanged: {
        if (explicitHorizontalAlignment) {
            textInput.horizontalAlignment = horizontalAlignment
        }
    }
    onExplicitHorizontalAlignmentChanged: {
        if (explicitHorizontalAlignment) {
            textInput.horizontalAlignment = horizontalAlignment
        } else {
            textInput.horizontalAlignment = undefined
        }
    }

    _editor: textInput
    _flickableDirection: Flickable.HorizontalFlick
    _singleLine: true
    errorHighlight: !textInput.acceptableInput

    implicitWidth: textInput.implicitWidth + Theme.paddingSmall + textLeftMargin + textRightMargin

    onReadOnlyChanged: _updateBackground()

    TextInput {
        id: textInput
        objectName: "textEditor"

        // Workaround for cursor delegate unable to reference directly to "textField"
        // Should be fixed in Qt5. To be verified...
        property alias cursorColor: textField.cursorColor

        onHorizontalAlignmentChanged: textField.setImplicitHorizontalAlignment(horizontalAlignment)

        x: -parent.contentX
        y: -parent.contentY
        width: implicitWidth < _minimumWidth ? _minimumWidth : implicitWidth
        focus: true
        activeFocusOnPress: false
        passwordCharacter: "\u2022"
        color: textField.color
        selectionColor: Theme.rgba(Theme.primaryColor, 0.3)
        selectedTextColor: Theme.highlightColor
        font: textField.font
        cursorDelegate: Rectangle {
            color: parent.cursorColor
            visible: parent.activeFocus && parent.selectedText == ""
            width: 2
        }

        PreeditText {
            id: preeditText

            onTextChanged: textField._fixupScrollPosition()
        }
    }
}
