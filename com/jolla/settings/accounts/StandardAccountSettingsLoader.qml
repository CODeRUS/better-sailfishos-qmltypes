import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

QtObject {
    id: root

    property bool autoEnableServices
    property bool autoEnableSyncSchedules: autoEnableServices

    property Account account
    property Provider accountProvider
    property AccountManager accountManager
    property AccountSyncManager accountSyncManager: AccountSyncManager {}

    property ListModel syncServices: ListModel {}
    property ListModel otherServices: ListModel {}

    property var serviceSyncProfiles: ({})
    property var _cachedSyncOptions: ([])

    signal settingsLoaded()

    // returns map of profile_id -> AccountSyncOptions for every profile id associated with this service
    function allSyncOptionsForService(serviceName) {
        var profiles = serviceSyncProfiles[serviceName]
        if (!profiles) {
            console.log("syncOptionsForService(): no match for service", serviceName)
            return []
        }
        if (_cachedSyncOptions[serviceName] === undefined) {
            var map = {}
            for (var i=0; i<profiles.length; i++) {
                var syncOptions = accountSyncManager.accountSyncOptions(profiles[i])
                if (syncOptions != null) {
                    if (autoEnableSyncSchedules && syncOptions.schedule != null) {
                        syncOptions.schedule.enabled = true
                    }
                    map[profiles[i]] = syncOptions
                }
            }
            _cachedSyncOptions[serviceName] = map
        }
        return _cachedSyncOptions[serviceName]
    }

    function setSyncOptionsForServiceProfile(serviceName, profileId, syncOptions) {
        var profiles = serviceSyncProfiles[serviceName]
        if (!profiles) {
            console.log("setSyncOptionsForServiceProfile(): no match for service: " + serviceName)
            return false
        }
        var found = false
        var foundProfileName = ""
        var i
        for (i = 0; i < profiles.length; i++) {
            if (profiles[i] === profileId) {
                foundProfileName = profiles[i]
                found = true
            }
        }
        if (found === false) {
            for (i = 0; i < profiles.length; i++) {
                if (profiles[i].indexOf(profileId) === 0) {
                    foundProfileName = profiles[i]
                    found = true
                }
            }
            if (found === false) {
                console.log("setSyncOptionsForServiceProfile(): no match for profile: " + profileId + " in service: " + serviceName)
                return false
            }
        }
        var allOptionsMap = allSyncOptionsForService(serviceName)
        allOptionsMap[foundProfileName] = syncOptions
        _cachedSyncOptions[serviceName] = allOptionsMap
        return true
    }

    function anySyncOptionsModified() {
        for (var serviceName in _cachedSyncOptions) {
            var profiles = _cachedSyncOptions[serviceName]
            for (var profileId in profiles) {
                var syncOptions = profiles[profileId]
                if (syncOptions.modified) {
                    return true;
                }
            }
        }
        return false
    }

    function updateProfilesForService(serviceName, extraProperties) {
        var optionsMap = allSyncOptionsForService(serviceName)
        for (var profileId in optionsMap) {
            accountSyncManager.updateProfile(profileId, extraProperties || {}, optionsMap[profileId])
        }
    }

    function updateAllSyncProfiles(extraProperties) {
        for (var serviceName in serviceSyncProfiles) {
            updateProfilesForService(serviceName, extraProperties)
        }
    }

    property Connections _conn: Connections {
        target: root.account

        onStatusChanged: {
            root._reload()
        }
    }

    function _reload() {
        if (!account || account.status != Account.Initialized) {
            return
        }
        syncServices.clear()
        otherServices.clear()
        var services = account.supportedServiceNames
        for (var i in services) {
            var service = accountManager.service(services[i])
            var serviceEnabled = false
            if (autoEnableServices) {
                account.enableWithService(service.name)
                serviceEnabled = true
            } else {
                serviceEnabled = account.isEnabledWithService(service.name)
            }

            var profileIds = accountSyncManager.profileIds(account.identifier, service.name)
            var labelText = ""
            var description = ""

            // don't show signon sync services, these are now invisible, used for signon refreshing.
            // those services were of type "sync" and ended in "-sync" (e.g., "facebook-sync")
            if (service.serviceType == "sync" && service.name.indexOf("-sync", service.name.length - 5) !== -1) {
                labelText = "" // deliberately unset the labelText for "sync" (signon) services.
            } else {
                labelText = AccountsUtil.serviceDisplayNameForService(service)
            }

            description = AccountsUtil.serviceDescription(service.serviceType, accountProvider.displayName, accountProvider.name)
            var props = {
                "serviceName": service.name,
                "iconName": service.iconName,
                "displayName": labelText,
                "enabled": serviceEnabled,
                "description": description
            }

            // scheduled synchronisation services usually appear in the syncServices section
            // with user-initiated services in the otherServices section.
            // we make an exception for "storage" services, to provide more description.
            if (profileIds.length > 0 && service.serviceType !== "storage") {
                syncServices.append(props)
            } else {
                // don't display services with no display text
                // as these have been explicitly marked, in code above.
                if (labelText.length > 0) {
                    otherServices.append(props)
                }
            }
            serviceSyncProfiles[service.name] = profileIds
        }
        settingsLoaded()
    }

    onAccountChanged: {
        _reload()
    }

    Component.onCompleted: {
        _reload()
    }
}
