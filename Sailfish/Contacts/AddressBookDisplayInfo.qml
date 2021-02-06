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

QtObject {
    property var addressBook
    property var simManager

    readonly property var _accountProvider: SailfishContacts.ContactAccountCache.accountManager.providerForAccount(addressBook.accountId)
    readonly property int _modemIndex: (!!simManager && addressBook.name === "SIM")
                                       ? simManager.indexOfModem(addressBook.extendedMetaData["ModemPath"])
                                       : -1

    readonly property string name: {
        if (addressBook.isAggregate) {
            // user shouldn't see this name
            return ""
        }
        if (addressBook.isLocal) {
            //: Name of address book containing contacts that are stored locally on the phone
            //% "Phone"
            return qsTrId("components_contacts-la-local_address_book")
        }
        if (_modemIndex >= 0) {
            return simManager.simNames[_modemIndex]
        }

        var accountWritableAddressBookCount = _accountProvider != null
                    ? SailfishContacts.ContactAccountCache.accountProviderAddressBooks[_accountProvider.name].length
                    : 0

        // If this is for an account, only show the address book name if there is more than one
        // address book for this provider, to avoid very long strings / excessive information.
        var name =  _accountProvider == null || accountWritableAddressBookCount > 1
                ? addressBook.name
                : ""
        var providerName = _accountProvider != null ? _accountProvider.displayName : ""
        if (name.length && providerName.length) {
            return name + " \u2022 " + providerName
        } else {
            return name || providerName
        }
    }

    readonly property string description: _modemIndex >= 0 ? "" : _account.defaultCredentialsUserName

    readonly property url iconUrl: SailfishContacts.ContactsUtil.addressBookIconUrl(addressBook, _accountProvider)

    readonly property var _account: Account {
        identifier: addressBook.accountId
    }
}
