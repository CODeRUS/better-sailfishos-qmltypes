import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import MeeGo.Connman 0.2
import Sailfish.Accounts 1.0
import org.nemomobile.contacts 1.0

Item {
    id: root

    function personalizeBroadcastNames() {
        if (_userDisplayNameSet) {
            _personalizeBroadcastNames()
        } else {
            displayNameFinder.start(_personalizeBroadcastNames)
        }
    }

    property string _userDisplayName
    property bool _userDisplayNameSet
    property QtObject _jollaAccountFinder
    property QtObject _selfContactLoader

    function _personalizeBroadcastNames() {
        var deviceName
        if (_userDisplayName == "") {
            deviceName = "Jolla"
        } else {
            //: Name of local Bluetooth device, set depending on user's name, e.g. "Heidi's Jolla"
            //% "%1's Jolla"
            deviceName = qsTrId("startupwizard-la-default_bluetooth_name").arg(_userDisplayName)
        }
        bluetoothAdapter.defaultName = deviceName
        wifiTechnology.tetheringId = deviceName
    }

    QtObject {
        id: displayNameFinder

        property var callbackWhenDone

        function start(callback) {
            callbackWhenDone = callback
            _selfContactLoader = selfContactComponent.createObject(root)
            _selfContactLoader.start()
        }

        function gotSelfContactName(name) {
            if (name !== "") {
                root._userDisplayName = name
                root._userDisplayNameSet = true
                callbackWhenDone()
            } else {
                _jollaAccountFinder = jollaAccountUsernameComponent.createObject(root)
                _jollaAccountFinder.start()
            }
        }

        function gotJollaAccountName(name) {
            root._userDisplayName = name
            root._userDisplayNameSet = true
            callbackWhenDone()
        }

        property Component selfContactComponent: Component {
            QtObject {
                function start() {
                    selfContact = peopleModel.selfPerson()
                    if (selfContact.complete) {
                        _loadName()
                    } else {
                        selfContact.completeChanged.connect(_loadName)
                    }
                }
                function _loadName() {
                    displayNameFinder.gotSelfContactName(selfContact.firstName.trim())
                }
                property PeopleModel peopleModel: PeopleModel {}
                property Person selfContact
            }
        }

        property Component jollaAccountUsernameComponent: Component {
            QtObject {
                function start() {
                    var accountIds = accountManager.accountIdentifiers
                    for (var i=0; i<accountIds.length; i++) {
                        var acc = accountManager.account(accountIds[i])
                        if (acc.providerName == "jolla") {
                            account.identifier = accountIds[i]
                            return
                        }
                    }
                    // no Jolla accounts found
                    displayNameFinder.gotJollaAccountName("")
                }
                property AccountManager accountManager: AccountManager {}
                property Account account: Account {
                    onStatusChanged: {
                        if (status == Account.Initialized) {
                            displayNameFinder.gotJollaAccountName(account.displayName)
                        } else if (status == Account.Error) {
                            // error or unexpected status change
                            displayNameFinder.gotJollaAccountName("")
                        }
                    }
                }
            }
        }
    }

    BluetoothAdapter {
        id: bluetoothAdapter
    }

    NetworkManagerFactory {
        id: networkManager
    }

    Connections {
        target: networkManager.instance
        onTechnologiesChanged: wifiTechnology.path = networkManager.instance.technologyPathForType("wifi")
    }

    NetworkTechnology {
        id: wifiTechnology
        path: networkManager.instance.technologyPathForType("wifi")
    }
}
