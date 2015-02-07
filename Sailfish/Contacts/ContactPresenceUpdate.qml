import Sailfish.Silica.private 1.0

DBusInterface {
    // Request an update from the service implemented by commhistoryd
    destination: "org.nemomobile.AccountPresence"
    path: "/org/nemomobile/AccountPresence"
    iface: "org.nemomobile.AccountPresenceIf"

    // 'state' should correspond to a member of SeasidePerson::PresenceState
    function setGlobalPresence(state, message) {
        if (message !== undefined) {
            call('setGlobalPresenceWithMessage', [state, message])
        } else {
            call('setGlobalPresence', state)
        }
    }

    // 'accountPath' should be the canonical account path, as reported
    // by SeasidePerson.accountPaths
    function setAccountPresence(accountPath, state, message) {
        if (message !== undefined) {
            call('setAccountPresenceWithMessage', [accountPath, state, message])
        } else {
            call('setAccountPresence', [accountPath, state])
        }
    }
}
