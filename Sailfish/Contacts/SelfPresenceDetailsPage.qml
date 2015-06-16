import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

PresenceDetailsPage {
    id: presencePage

    property Person self: Person.selfPerson

    // Load the presence information from the selfPerson object
    globalPresenceState: self.globalPresenceState

    function getPresenceAccounts() {
        return self ? self.accountDetails : []
    }

    onSelfChanged: updatePresenceModel()

    Connections {
        target: self
        onAccountDetailsChanged: scheduleUpdatePresenceModel()
    }
}
