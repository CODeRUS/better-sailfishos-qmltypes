/*
* Copyright (c) 2020 Open Mobile Platform LLC.
*
* License: Proprietary
*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import Sailfish.Accounts 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    property alias contactPrimaryName: nameRow.firstText
    property alias contactSecondaryName: nameRow.secondText
    property alias addressBook: addressBookInfo.addressBook
    property alias simManager: addressBookInfo.simManager

    property int leftMargin: Theme.horizontalPageMargin
    property int rightMargin: Theme.horizontalPageMargin

    readonly property bool _highlighted: highlighted

    width: parent.width
    height: Theme.itemSizeMedium
    opacity: enabled ? 1.0 : Theme.opacityLow

    HighlightImage {
        id: icon

        anchors {
            left: parent.left
            leftMargin: root.leftMargin
            verticalCenter: parent.verticalCenter
        }
        sourceSize.width: Theme.iconSizeMedium
        sourceSize.height: Theme.iconSizeMedium
        source: addressBookInfo.iconUrl
        monochromeWeight: SailfishContacts.ContactsUtil.iconMonochromeWeight(icon)
    }

    ContactNameRow {
        id: nameRow

        anchors {
            left: icon.right
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: root.rightMargin
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: addressBookName.text.length ? -addressBookName.height/2 : 0
        }

        unnamed: firstText === SailfishContacts.ContactModelCache.unfilteredModel().placeholderDisplayLabel
        useAlternateColors: false   // since this is a two-line item, use same colors for both names
    }

    Label {
        id: addressBookName

        anchors {
            left: icon.right
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            top: nameRow.bottom
        }

        text: addressBookInfo.name
              + (addressBookInfo.description.length
                 ? " \u2022 " + addressBookInfo.description
                 : "")
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }

    AddressBookDisplayInfo {
        id: addressBookInfo
    }
}
