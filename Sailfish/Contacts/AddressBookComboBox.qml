/*
* Copyright (c) 2020 Open Mobile Platform LLC.
*
* License: Proprietary
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

IconComboBox {
    id: root

    property alias addressBookModel: addressBookModel
    property alias addressBookRepeater: addressBookRepeater

    signal addressBookClicked(var addressBook)

    leftMargin: Theme.paddingLarge
    value: currentItem
           ? currentItem.text + (currentItem.description.length ? " \u2022 " + currentItem.description : "")
           : ""

    menu: ContextMenu {
        Repeater {
            id: addressBookRepeater

            model: AddressBookModel {
                id: addressBookModel
            }

            delegate: IconMenuItem {
                x: root.leftMargin
                text: addressBookInfo.name
                description: addressBookInfo.description
                icon.source: addressBookInfo.iconUrl
                icon.monochromeWeight: SailfishContacts.ContactsUtil.iconMonochromeWeight(icon)

                visible: !model.addressBook.isAggregate && !model.addressBook.readOnly

                onClicked: {
                    root.addressBookClicked(model.addressBook)
                }

                AddressBookDisplayInfo {
                    id: addressBookInfo

                    addressBook: model.addressBook

                    // Don't need to set simManager, as SIM address book is read-only and won't be
                    // visible in the combo box.
                }
            }
        }
    }
}
