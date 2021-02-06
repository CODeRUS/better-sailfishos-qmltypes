/****************************************************************************************
**
** Copyright (c) 2013 - 2019 Jolla Pty Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
** All rights reserved.
**
** This file is part of Sailfish text linking component package.
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    Component {
        id: personComponent
        Person {}
    }

    function handleLink(link) {
        if (typeof(link.indexOf) == "undefined") {
            // Link can be url as well, try to convert to string
            link = link.toString()
        }

        var colonIdx = link.indexOf(':')
        if (colonIdx <= 0) {
            console.log("Link does not contain scheme part. Don't know how to handle!")
            return
        }
        var paramIdx = link.indexOf('?')
        if (paramIdx == -1) {
            paramIdx = undefined
        }

        var scheme = link.substring(0, colonIdx)
        var address = link.substring(colonIdx + 1, paramIdx)

        if (address === "") {
            console.log("Link does not contain address part. Don't know how to handle!")
            return
        }

        if (scheme == "tel" || scheme == "sms" || scheme == "mailto") {
            var person = personComponent.createObject(root)
            if (scheme == "mailto") {
                person.emailDetails = [ {
                    'type': Person.EmailAddressType,
                    'address': address,
                    'index': -1
                } ]
            } else {
                person.phoneDetails = [ {
                    'type': Person.PhoneNumberType,
                    'number': decodeURIComponent(address),
                    'index': -1
                } ]
            }
            pageStack.animatorPush("Sailfish.Contacts.ContactCardPage", { contact: person })
        } else {
            Qt.openUrlExternally(link)
        }
    }
}
