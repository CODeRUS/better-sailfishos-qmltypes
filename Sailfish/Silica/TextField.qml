/****************************************************************************************
**
** Copyright (C) 2013-2019 Jolla Ltd.
** Copyright (C) 2020 Open Mobile Platform LLC.
**
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
    property int inputMethodHints
    property alias inputMethodComposing: textInput.inputMethodComposing
    property alias validator: proxyValidator.validator
    property alias echoMode: textInput.echoMode
    property alias cursorPosition: textInput.cursorPosition
    property alias wrapMode: textInput.wrapMode
    property alias selectedText: textInput.selectedText
    property alias selectionStart: textInput.selectionStart
    property alias selectionEnd: textInput.selectionEnd
    property bool acceptableInput: textInput.acceptableInput
    property alias passwordCharacter: textInput.passwordCharacter
    property alias passwordMaskDelay: textInput.passwordMaskDelay
    property alias maximumLength: textInput.maximumLength
    property alias length: textInput.length
    property alias strictValidation: proxyValidator.strictValidation

    property bool _cursorBlinkEnabled: true
    property real _minimumWidth: textField.width - Theme.paddingSmall - textField._totalLeftMargins
                                 - textField._totalRightMargins - textField._rightItemWidth
    property bool __silica_textfield: true

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
    _flickableDirection: Flickable.VerticalFlick
    errorHighlight: textInput.touched && !textField.acceptableInput

    onReadOnlyChanged: _updateBackground()

    TextInput {
        id: textInput
        objectName: "textEditor"

        // Workaround for cursor delegate unable to reference directly to "textField"
        // Should be fixed in Qt5. To be verified...
        property alias cursorColor: textField.cursorColor
        property bool touched

        onActiveFocusChanged: if (!activeFocus) touched = true
        onTextChanged: if (activeFocus) touched = true

        onHorizontalAlignmentChanged: textField.setImplicitHorizontalAlignment(horizontalAlignment)

        x: -parent.contentX + textField.textLeftPadding
        y: -parent.contentY + textField.textTopPadding
        width: textField._minimumWidth
        focus: true
        activeFocusOnPress: false
        passwordCharacter: "\u2022"
        color: textField.color
        selectionColor: Theme.rgba(textField.palette.primaryColor, 0.3)
        selectedTextColor: textField.palette.highlightColor
        font: textField.font
        cursorDelegate: Cursor {
            color: textField.cursorColor
            preedit: preeditText
            _blinkEnabled: textField._cursorBlinkEnabled
        }
        validator: proxyValidator.validator ? proxyValidator : null

        // JB#45985 and QTBUG-37850: Qt was changed to mess up with virtual keyboard state when enter key
        // is handled. Work around by always forcing multiline hint for this single line entry
        inputMethodHints: textField.inputMethodHints | Qt.ImhMultiLine

        ProxyValidator {
            id: proxyValidator
        }

        PreeditText {
            id: preeditText

            onTextChanged: {
                textField._fixupScrollPosition()
                if (activeFocus) {
                    textInput.touched = true
                }
            }
        }

        states: State {
            when: textInput.wrapMode === TextInput.NoWrap
            PropertyChanges {
                target: textField
                _flickableDirection: Flickable.HorizontalFlick
                _singleLine: true
            }
            PropertyChanges {
                target: textInput
                width: Math.max(_minimumWidth, implicitWidth)
            }
        }
    }
}
