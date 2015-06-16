import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0
import "accountutil.js" as AccountUtil

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
            if (profileIds.length > 0) {
                labelText = AccountUtil.serviceDisplayName(service.name, service.displayName)
            } else {
                if (service.serviceType == "sync") {
                    // Sync services are now split up into individual services, so
                    // don't show this service anymore.
                    continue
                }
                labelText = AccountUtil.serviceDisplayNameFromType(service.serviceType, service.displayName)
            }
            description = AccountUtil.serviceDescription(service.serviceType, accountProvider.displayName, accountProvider.name)
            var props = {
                "serviceName": service.name,
                "iconName": service.iconName,
                "displayName": labelText,
                "enabled": serviceEnabled,
                "description": description
            }
            if (profileIds.length > 0) {
                syncServices.append(props)
            } else {
                otherServices.append(props)
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
