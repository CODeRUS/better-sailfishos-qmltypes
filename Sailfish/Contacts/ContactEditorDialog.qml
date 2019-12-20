/*
 * Copyright (c) 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import Sailfish.Silica.private 1.0 as Private
import org.nemomobile.contacts 1.0
import "detaileditors"

/**
 * Main editor page that contains sections for each type of contact detail.
 * These sections and their names are populated on this page, but each section
 * populates its own data from the contact object that is passed from here to
 * them.
 */
Dialog {
    id: root

    property var peopleModel
    property Person subject
    property var focusField

    property variant _originalContactData
    property Person _contact: subject && subject.complete ? subject : null
    property var _peopleModel: peopleModel || SailfishContacts.ContactModelCache.unfilteredModel()
    property var _editors: [name, company, phone, email, note, address, date, website, info]

    function findNextItemInFocusChain(fromItem, editor) {
        // When focused on last editor, don't loop focus back to the first editor.
        var nextItem = fromItem.nextItemInFocusChain(true)
        return nextItem === name.detailEditors.itemAt(0) ? null : nextItem
    }

    canAccept: _contact !== null && name.hasContent

    onAcceptBlocked: {
        // Name has not been entered. Focus the field to indicate it is required.
        name.focusFieldAt(0)
    }

    onDone: {
        if (result === DialogResult.Accepted) {
            flick.save()
            if (!_peopleModel.savePerson(_contact)) {
                console.log("Contact save failed!")
            }
        } else {
            // Reset the contact back to its initial state
            _contact.setContactData(_originalContactData)
            if (_contact.id != 0) {
                _contact.resetContactData()
            }
        }

        // Close vkb
        focus = true
    }

    SilicaFlickable {
        id: flick

        property bool completed
        property bool activated

        property Person contact: root._contact
        onContactChanged: {
            if (contact && completed) {
                activate()
            }
        }

        function activate() {
            if (!activated) {
                activated = true

                nicknames.reload(contact[nicknames.propertyAccessor])
                for (var i = 0; i < _editors.length; ++i) {
                    _editors[i].populateFieldEditor()
                    _editors[i].populated = true
                }

                root._originalContactData = root._contact.contactData()
                if (_contact.id == 0) {
                    editorsColumn.focusInitialField()
                } else if (!!focusField) {
                    editorsColumn.focusSpecificField()
                }
            }
        }

        function save() {
            for (var i = 0; i < _editors.length; ++i) {
                _editors[i].aboutToSave()
            }
            nicknames.copyMultiTypeDetailChanges(contact, nicknames.propertyAccessor)
        }

        anchors.fill: parent
        contentHeight: editorsColumn.height + header.height
        contentWidth: parent.width

        Component.onCompleted: {
            completed = true
            if (root._contact != null) {
                activate()
            }
        }

        SailfishContacts.ContactDetailSuggestions {
            id: fieldSuggestions

            property alias inputItem: autoFill.inputItem
        }

        Private.AutoFill {
            id: autoFill

            suggestions: fieldSuggestions.suggestions
            canRemove: false
            inputItem: null
        }

        DialogHeader {
            id: header
            dialog: root
        }

        Column {
            id: editorsColumn

            anchors.top: header.bottom
            width: parent.width

            property bool focusOnActivated
            property bool appActivated: Qt.application.active && root.status == PageStatus.Active
            onAppActivatedChanged: {
                if (appActivated && focusOnActivated) {
                    focusOnActivated = false
                    focusInitialField()
                }
            }
            function focusInitialField() {
                if (appActivated) {
                    name.focusFieldAt(0)
                } else {
                    editorsColumn.focusOnActivated = true
                }
            }
            function focusSpecificField() {
                var editor = null
                switch (focusField.detailType) {
                    case "name":    editor = name;    break;
                    case "company": editor = company; break;
                    case "phone":   editor = phone;   break;
                    case "email":   editor = email;   break;
                    case "note":    editor = note;    break;
                    case "address": editor = address; break;
                    case "date":    editor = date;    break;
                    case "website": editor = website; break;
                    case "info":    editor = info;    break;
                    default: console.log("Unknown detail type: " + focusField.detailType); return;
                }
                editor.focusFieldAt(focusField.detailIndex, editor.animationDuration)
            }

            Item {
                width: parent.width
                height: name.height + avatarMenuContainer.height + company.height

                // Background highlight behind name and company sections
                Rectangle {
                    y: -Theme.paddingLarge // compensate for DialogHeader padding
                    width: parent.width
                    height: parent.height - y
                            - Theme.paddingSmall    // prevent highlight from running into 'clear' icon in the following textfield
                    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                }

                ContactAvatar {
                    id: avatar

                    x: Theme.horizontalPageMargin
                    width: Theme.itemSizeExtraLarge
                    contentHeight: Theme.itemSizeExtraLarge
                    contact: root._contact
                    menuParent: avatarMenuContainer
                }

                NameEditor {
                    id: name

                    anchors {
                        left: avatar.right
                        leftMargin: Theme.paddingLarge
                        right: parent.right
                        top: parent.top
                        topMargin: -Theme.paddingMedium // roughly align with top of avatar
                    }

                    contact: root._contact
                    peopleModel: root._peopleModel
                    acceptMouseClicks: !flick.moving
                    nicknameModel: nicknames
                    flickable: flick
                }

                Item {
                    id: avatarMenuContainer

                    anchors.top: name.bottom
                    width: parent.width
                    height: avatar._contextMenu ? avatar._contextMenu.height : 0
                }

                CompanyEditor {
                    id: company

                    anchors.top: avatarMenuContainer.bottom
                    contact: root._contact
                    peopleModel: root._peopleModel
                    suggestions: fieldSuggestions
                    acceptMouseClicks: !flick.moving
                }
            }

            PhoneEditor {
                id: phone

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
            }

            EmailEditor {
                id: email

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
            }

            NoteEditor {
                id: note

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
            }

            AddressEditor {
                id: address

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
            }

            DateEditor {
                id: date

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
            }

            WebsiteEditor {
                id: website

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
            }

            InfoEditor {
                id: info

                contact: root._contact
                peopleModel: root._peopleModel
                acceptMouseClicks: !flick.moving
                nicknameModel: nicknames
                suggestions: fieldSuggestions
            }
        }

        VerticalScrollDecorator { }
    }

    NicknameDetailModel {
        id: nicknames
    }
}
