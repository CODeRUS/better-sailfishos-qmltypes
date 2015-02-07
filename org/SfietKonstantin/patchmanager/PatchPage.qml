/*
 * Copyright (C) 2013 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * The names of its contributors may not be used to endorse or promote
 *     products derived from this software without specific prior written
 *     permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: container
    property alias name: name.text
    property alias description: description.text
    property QtObject delegate
    property bool available
    signal doPatch

    SilicaFlickable {
        id: view
        anchors.fill: parent

        Column {
            width: view.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Patch information"
            }

            Label {
                visible: !container.available
                color: Theme.primaryColor
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                text: "This patch is no available anymore. You won't be able to reinstall it."
            }

            Label {
                id: name
                color: Theme.highlightColor
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
            }


            Label {
                id: description
                color: Theme.highlightColor
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.WordWrap
            }
        }

        PullDownMenu {
            enabled: !container.delegate.applying || active
            MenuItem {
                text: container.delegate.applying ? "Patch being applied" : (container.delegate.applied ? "Unapply patch" : "Apply patch")
                enabled: !container.delegate.applying
                onClicked: {
                    container.delegate.doPatch()
                    if (!container.available) {
                        pageStack.pop()
                    }
                }
            }
        }
    }
}
