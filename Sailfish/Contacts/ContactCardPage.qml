/*
 * Copyright (c) 2013 - 2019 Jolla Pty Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

Page {
    id: root

    property alias contact: contactCard.contact
    property bool promptLinkImmediately

    // Whether to show the pulley menu with Delete, Share, Edit etc.
    property alias actionsEnabled: pullDownMenu.visible

    property alias activeDetail: contactCard.activeDetail

    property var _unsavedContact

    function showError(errorText) {
        if (errorText) {
            errorLabel.text = errorText
            contactLoadingBusy.running = false
        }
    }

    onContactChanged: {
        if (!contact) {
            contactLoadingBusy.running = false
        } else if (contact && contact.id === 0 && !_unsavedContact) {
            _unsavedContact = unsavedContactComponent.createObject(root)
        }
    }

    Component.onCompleted: {
        if (contact && contact.id === 0 && !_unsavedContact) {
            _unsavedContact = unsavedContactComponent.createObject(root)
        }
        if (promptLinkImmediately) {
            pullDownMenu.triggerLinkAction()
        }
    }

    Component {
        id: unsavedContactComponent

        UnsavedContactCardHandler {
            contactCardPage: root
            contact: !!root.contact && root.contact.id === 0 ? root.contact : null
            peopleModel: SailfishContacts.ContactModelCache.unfilteredModel()

            // If the unsaved contact is resolved or saved, update the card to show the resolved
            // or saved contact.
            onResolvedToContact: contactCard.contact = contact
            onSavedAsContact: contactCard.contact = contact

            // If the contact becomes aggregated into another contact, show that contact instead.
            onAggregatedIntoContact: contactCard.contact = contact

            onActiveDetailChanged: contactCard.activeDetail = activeDetail
            onError: root.showError(errorText)
        }

    }

    PageBusyIndicator {
        id: contactLoadingBusy

        running: contact == null
                 || (_unsavedContact != null && _unsavedContact.busy)
    }

    Label {
        id: errorLabel

        x: Theme.horizontalPageMargin
        width: parent.width - Theme.horizontalPageMargin*2
        anchors.centerIn: parent

        //% "Contact not found"
        text: qsTrId("components_contacts-la-contact_not_found")
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.highlightColor
        visible: contact == null && !contactLoadingBusy.running
    }

    ContactCard {
        id: contactCard

        visible: !contactLoadingBusy.running && !errorLabel.visible
        opacity: 1 - contactLoadingBusy.opacity

        ContactCardPullDownMenu {
            id: pullDownMenu

            visible: contact != null
            page: root
            contact: contactCard.contact
            peopleModel: SailfishContacts.ContactModelCache.unfilteredModel()

            onUnsavedContactLinkRequested: {
                if (_unsavedContact != null) {
                    _unsavedContact.selectContactToLink(PageStackAction.Animated)
                }
            }

            MenuItem {
                //: Save contact
                //% "Save"
                text: qsTrId("components_contacts-me-save")
                visible: _unsavedContact != null
                         && _unsavedContact.contact != null
                         && _unsavedContact.contact.id === 0

                onClicked: {
                    ContactsUtil.editContact(_unsavedContact.contact,
                                             SailfishContacts.ContactModelCache.unfilteredModel(),
                                             pageStack,
                                             {
                                                 "acceptDestination": root,
                                                 "acceptDestinationAction": PageStackAction.Pop,
                                             })
                }
            }
        }
    }
}
