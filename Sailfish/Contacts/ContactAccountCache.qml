/*
 * Copyright (c) 2013 - 2019 Jolla Pty Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

pragma Singleton

import QtQuick 2.6
import Sailfish.Accounts 1.0
import org.nemomobile.contacts 1.0

QtObject {
    id: root

    // Map of account provider name -> address books
    property var accountProviderAddressBooks: {
        var ret = {}
        var addressBooks = AddressBookUtil.addressBooks
        for (var i = 0; i < addressBooks.length; ++i) {
            if (addressBooks[i].readOnly) {
                continue
            }
            var providerForAccount = accountManager.providerForAccount(addressBooks[i].accountId)
            if (providerForAccount != null) {
                if (ret[providerForAccount.name] === undefined) {
                    ret[providerForAccount.name] = []
                }
                if (ret[providerForAccount.name].indexOf(addressBooks[i].name) < 0) {
                    ret[providerForAccount.name].push(addressBooks[i].name)
                }
            }
        }
        return ret
    }

    property var accountManager: AccountManager {}
}
