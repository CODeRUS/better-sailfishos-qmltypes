pragma Singleton

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Telephony 1.0
import MeeGo.QOfono 0.2
import org.nemomobile.dbus 2.0
import org.nemomobile.ofono 1.0
import org.nemomobile.contacts 1.0
import org.freedesktop.contextkit 1.0
import org.nemomobile.messages.internal 1.0

QtObject {
    readonly property bool debug: false

    property var attachedComponentCache

    readonly property bool multipleEnabledSimCards: simManager.valid && simManager.activeSimCount > 1

    // cellular configs will have one account by default(SMS) installed by telepathy-ring
    readonly property bool hasModemOrIMaccounts: _capabilityDataContextProperty.value || telepathyAccounts.count > 0
    readonly property bool hasModem: _capabilityDataContextProperty.value || _capabilityDataContextProperty.value === undefined

    readonly property string voiceModemPath: {
        if (simManager.valid) {
            if (Telephony.promptForMessageSim) {
                return _requestedModemPath
            } else if (simManager.activeModem) {
                return simManager.activeModem
            } else if (simManager.voiceModem) {
                return simManager.voiceModem
            }
        }
        return (_ofonoModemManager.defaultVoiceModem || _ofonoManager.defaultModem)
    }

    property var _ofonoModemManager: OfonoModemManager {}
    property var _ofonoManager: OfonoManager {}
    property string _requestedModemPath

    property var simManager: SimManager {
        controlType: SimManagerType.Voice
    }

    property var telepathyAccounts: TelepathyAccountsModel {
        readonly property string ringAccountPath: "/org/freedesktop/Telepathy/Account/ring/tel" + voiceModemPath

        function selectModem(modemPath) {
            _requestedModemPath = modemPath
        }

        function displayName(localUid) {
            if (localUid !== undefined && isSMS(localUid)) {
                //% "Text message"
                return qsTrId("messages-va-text_message")
            } else if (!telepathyAccounts.ready) {
                return ""
            } else {
                var name = telepathyAccounts.get(localUid)
                if (name == null || name.length < 1) {
                    //: Name for unknown/invalid messaging accounts
                    //% "Unknown"
                    return qsTrId("messages-la-unknown_account")
                }
                return name
            }
        }
    }

    property var peopleModel: PeopleModel {
        // Use FilterNone to suppress any contact results, since we don't need to
        // report any contacts except when used in the search function of NewMessagePage
        filterType: PeopleModel.FilterNone
    }

    property var _capabilityDataContextProperty: ContextProperty {
        key: "Cellular.CapabilityData"
    }

    property var _settingsDBus: DBusInterface {
        id: settingsDBus

        service: "com.jolla.settings"
        path: "/com/jolla/settings/ui"
        iface: "com.jolla.settings.ui"
    }

    property var _pinQueryDBus: DBusInterface {
        service: "com.jolla.PinQuery"
        path: "/com/jolla/PinQuery"
        iface: "com.jolla.PinQuery"
    }

    function personAccount(person, localUid, remoteUid) {
        if (person === null || !person)
            return undefined

        var accounts = person.accountDetails
        for (var i = 0; i < accounts.length; i++) {
            var account = accounts[i]
            if (account.accountPath === localUid && account.accountUri === remoteUid)
                return account
        }

        return undefined
    }

    function presenceForPersonAccount(person, localUid, remoteUid) {
        var account = personAccount(person, localUid, remoteUid)
        if (account) {
            return account.presenceState
        }

        return 0
    }

    function accountDisplayName(person, localUid, remoteUid) {
        var account = personAccount(person, localUid, remoteUid)
        if (account) {
            if (account.serviceProviderDisplayName)
                return account.serviceProviderDisplayName
        }

        // Fall back to telepathy
        return telepathyAccounts.displayName(localUid)
    }

    function isSMS(localUid) {
        return localUid && localUid.indexOf("/ring/tel") >= 0
    }

    function testCanUseSim(simErrorState) {
        if (simErrorState === "modemDisabled" || simErrorState === "noSimInserted") {
            showSimCardsSettings()
            return false
        } else if (simErrorState === "simActivationRequired") {
            requestSimPin()
            return false
        }
        return true
    }

    function showSimCardsSettings() {
        _settingsDBus.call("showPage", "system_settings/connectivity/multisim")
    }

    function requestSimPin() {
        if (voiceModemPath) {
            _pinQueryDBus.call("requestSimPin", [ voiceModemPath ])
        }
    }

    function findPersonAndPhoneDetails(phoneNumber, people) {
        phoneNumber = Person.minimizePhoneNumber(phoneNumber)

        for (var i = 0; i < people.length; i++) {
            var person = people[i]
            var details = person.removeDuplicatePhoneNumbers(person.phoneDetails)
            var matchingDetailIndex = -1
            var matchingDetail

            for (var j = 0; j < details.length; j++) {
                var detail = details[j]

                if (Person.minimizePhoneNumber(detail.number) === phoneNumber) {
                    matchingDetailIndex = j
                    matchingDetail = detail
                    break
                }
            }

            if (matchingDetail) {
                var duplicateLabel = false

                for (j = 0; j < details.length; j++) {
                    detail = details[j]

                    if (j === matchingDetailIndex) {
                        continue
                    } else if (detail.type === matchingDetail.type && detail.label === matchingDetail.label) {
                        duplicateLabel = true
                        break
                    }
                }

                return {
                    "phoneDetail": matchingDetail,
                    "phoneDetails": details,
                    "person": person,
                    "duplicateLabel": duplicateLabel
                }
            }
        }

        return null
    }

    function phoneDetailsString(phoneNumber, people) {
        var d = findPersonAndPhoneDetails(phoneNumber, people)
        if (!d || d.phoneDetails.length <= 1) {
            return ""
        }

        ContactsUtil.init()
        var detail = d.phoneDetail
        var label = ContactsUtil.getNameForDetailSubType(detail.type, detail.subTypes, detail.label)

        if (!label) {
            return phoneNumber
        } else if (d.duplicateLabel) {
            // Don't show labels if they are the same for all numbers as then they don't help
            return phoneNumber
        } else {
            return label
        }
    }
}
