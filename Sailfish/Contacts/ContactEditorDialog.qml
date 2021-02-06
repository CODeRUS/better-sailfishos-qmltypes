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
    property var focusField: ({})

    property var _originalContactData
    property Person _contact: subject && subject.complete && !_readOnly ? subject : null
    property var _peopleModel: peopleModel || SailfishContacts.ContactModelCache.unfilteredModel()
    property var _editors: [name, company, phone, email, note, address, date, website, info]
    readonly property bool _readOnly: !subject
                                      || !subject.complete
                                      || !ContactsUtil.isWritableContact(subject)

    function findNextItemInFocusChain(fromItem, editor) {
        // When focused on last editor, don't loop focus back to the first editor.
        var nextItem = fromItem.nextItemInFocusChain(true)
        return nextItem === name.detailEditors.itemAt(0) ? null : nextItem
    }

    function hasDetailedContent() {
        for (var i = 0; i < _editors.length; i++) {
            if (_editors[i].hasContent) {
                return true
            }
        }
        return false
    }

    InfoLabel {
        anchors.centerIn: parent
        visible: !flick.visible
        //% "This contact cannot be modified"
        text: qsTrId("components_contacts-la-contact_cannot_be_modified")
    }

    canAccept: !_readOnly && hasDetailedContent() && addressBookCombo.currentIndex >= 0

    onAcceptBlocked: {
        // Name has not been entered. Focus the field to indicate it is required.
        root.focusField = { detailType: "name", detailIndex: 0 }
    }

    onDone: {
        if (result === DialogResult.Accepted) {
            // Break the binding so that if contact state changes while saving and this affects the
            // id and readOnly state, the editor will not suddenly disappear.
            flick.visible = true

            flick.save()
            if (!_peopleModel.savePerson(_contact)) {
                console.log("Contact save failed!")
            } else {
                addressBookCombo.saveDefaultAddressBook()
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

    on_ContactChanged: {
        if (_contact) {
            _originalContactData = _contact.contactData()
        }
    }

    SilicaFlickable {
        id: flick

        function save() {
            for (var i = 0; i < _editors.length; ++i) {
                _editors[i].aboutToSave()
            }
            nicknames.copyMultiTypeDetailChanges(root._contact, nicknames.propertyAccessor)
        }

        anchors.fill: parent
        contentHeight: editorsColumn.height + header.height
        contentWidth: parent.width
        visible: !root._readOnly

        // Delay loading so that the editor doesn't appear abruptly when pushing immediately from
        // the constituent picker.
        NumberAnimation on opacity {
            from: 0
            to: 1
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

            Item {
                width: parent.width
                height: addressBookCombo.y + addressBookCombo.height

                // Background highlight behind name, company and address book sections
                Rectangle {
                    y: -Theme.paddingLarge // compensate for DialogHeader padding
                    width: parent.width
                    height: parent.height - y
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
                    nicknameModel: nicknames
                    flickable: flick
                    initialFocusIndex: focusField.detailType === "name" || focusField.detailType === undefined
                                       ? focusField.detailIndex || 0
                                       : -1
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
                    initialFocusIndex: focusField.detailType === "company" ? focusField.detailIndex : -1
                }

                ContactAddressBookComboBox {
                    id: addressBookCombo

                    anchors.top: company.bottom
                    contact: root._contact
                    enabled: root._contact != null && root._contact.id === 0
                }
            }

            PhoneEditor {
                id: phone

                contact: root._contact
                peopleModel: root._peopleModel
                initialFocusIndex: focusField.detailType === "phone" ? focusField.detailIndex : -1
            }

            EmailEditor {
                id: email

                contact: root._contact
                peopleModel: root._peopleModel
                initialFocusIndex: focusField.detailType === "email" ? focusField.detailIndex : -1
            }

            NoteEditor {
                id: note

                contact: root._contact
                peopleModel: root._peopleModel
                initialFocusIndex: focusField.detailType === "note" ? focusField.detailIndex : -1
            }

            AddressEditor {
                id: address

                contact: root._contact
                peopleModel: root._peopleModel
                initialFocusIndex: focusField.detailType === "address" ? focusField.detailIndex : -1
            }

            DateEditor {
                id: date

                contact: root._contact
                peopleModel: root._peopleModel
                // initialFocusIndex not set, date field cannot be focused
            }

            WebsiteEditor {
                id: website

                contact: root._contact
                peopleModel: root._peopleModel
                initialFocusIndex: focusField.detailType === "website" ? focusField.detailIndex : -1
            }

            InfoEditor {
                id: info

                contact: root._contact
                peopleModel: root._peopleModel
                nicknameModel: nicknames
                suggestions: fieldSuggestions
                initialFocusIndex: focusField.detailType === "info" ? focusField.detailIndex : -1
            }
        }

        VerticalScrollDecorator { }
    }

    NicknameDetailModel {
        id: nicknames

        contact: root._contact
    }
}
