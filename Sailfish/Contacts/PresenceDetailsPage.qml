import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Page {
    id: presencePage
    property Person self: Person.selfPerson

    onSelfChanged: updatePresenceModel()

    Connections {
        target: self
        onAccountDetailsChanged: scheduleUpdatePresenceModel()
    }

    function scheduleUpdatePresenceModel() {
        // We usually get all change signals at once - only react to them once
        updateTimer.restart()
    }

    Timer {
        id: updateTimer
        interval: 1
        onTriggered: updatePresenceModel()
    }

    function updatePresenceModel() {
        if (self) {
            var accounts = self.accountDetails
            var i; var j; var account

            // Remove any items no longer present
            for (i = presenceModel.count; i > 0; --i) {
                var path = presenceModel.get(i-1).path
                for (j = 0; j < accounts.length; ++j) {
                    if (accounts[j].accountPath == path) {
                        break
                    }
                }
                if (j == accounts.length) {
                    presenceModel.remove(i-1)
                }
            }

            for (i = 0; i < accounts.length; ++i) {
                account = accounts[i]

                for (j = 0; j < presenceModel.count; ++j) {
                    if (presenceModel.get(j).path == account.accountPath) {
                        break
                    }
                }

                if (j == presenceModel.count) {
                    // Append this new account to the model
                    presenceModel.append({
                        'path': account.accountPath,
                        'uri': account.accountUri,
                        'provider': account.serviceProviderDisplayName != "" ? account.serviceProviderDisplayName : account.serviceProvider,
                        'accountName': account.accountDisplayName,
                        'iconPath': account.iconPath,
                        'presenceState': account.presenceState,
                        'message': account.presenceMessage,
                        'enabled': account.enabled
                    })
                } else {
                    // Update any properties that may have changed
                    presenceModel.set(j, {
                        'presenceState': account.presenceState,
                        'message': account.presenceMessage
                    })
                }
            }
        } else {
            presenceModel.clear()
        }
    }

    function presenceDescription(presenceState) {
        switch (presenceState) {
            //: Presence state: available
            //% "Available"
            case Person.PresenceAvailable: return qsTrId("components_contacts-la-presence_available")
            //: Presence state: away
            //% "Away"
            case Person.PresenceAway: return qsTrId("components_contacts-la-presence_away")
            //: Presence state: extended away
            //% "Extended away"
            case Person.PresenceExtendedAway: return qsTrId("components_contacts-la-presence_extended_away")
            //: Presence state: busy
            //% "Busy"
            case Person.PresenceBusy: return qsTrId("components_contacts-la-presence_busy")
            //: Presence state: hidden
            //% "Hidden"
            case Person.PresenceHidden: return qsTrId("components_contacts-la-presence_hidden")
            //: Presence state: offline
            //% "Offline"
            case Person.PresenceOffline: return qsTrId("components_contacts-la-presence_offline")
            //: Presence state: unknown
            //% "Unknown"
            case Person.PresenceUnknown: return qsTrId("components_contacts-la-presence_unknown")
        }
        return '<Unknown:' + presenceState + '>'
    }

    ListModel { id: presenceModel }

    ContactPresenceUpdate {
        id: presenceUpdate
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator {}

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: header
                //% "Presence"
                title: qsTrId("components_contacts-he-presence_details")
            }

            Row {
                id: presenceSwitches
                PresenceSwitch {
                    id: offlineSwitch
                    presenceState: Person.PresenceOffline
                    width: presencePage.width / 3
                    onClicked: {
                        awaySwitch.cancelBusy()
                        availableSwitch.cancelBusy()
                    }
                }
                PresenceSwitch {
                    id: awaySwitch
                    presenceState: Person.PresenceAway
                    width: presencePage.width / 3
                    onClicked: {
                        offlineSwitch.cancelBusy()
                        availableSwitch.cancelBusy()
                    }
                }
                PresenceSwitch {
                    id: availableSwitch
                    presenceState: Person.PresenceAvailable
                    width: presencePage.width / 3
                    onClicked: {
                        offlineSwitch.cancelBusy()
                        awaySwitch.cancelBusy()
                    }
                }
            }

            SectionHeader {
                //: List of services with presence that the global switches affect
                //% "Controlled services"
                text: qsTrId("components_contacts-la-controlled_services")
            }

            Repeater {
                model: presenceModel

                delegate: ListItem {
                    property var path: presenceModel.get(index).path
                    width: parent.width
                    contentHeight: icon.height
                    enabled: model.enabled
                    menu: Component {
                        ContextMenu {
                            function presenceSelection(index) {
                                switch (index) {
                                    case 0: return Person.PresenceAvailable
                                    case 1: return Person.PresenceAway
                                    case 2: return Person.PresenceBusy
                                    case 3: return Person.PresenceHidden
                                    default: return Person.PresenceOffline
                                }
                            }

                            Repeater {
                                model: 5
                                MenuItem {
                                    property int presence: presenceSelection(index)
                                    text: presenceDescription(presence)
                                    onClicked: presenceUpdate.setAccountPresence(path, presence)
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: icon
                        width: Theme.iconSizeLarge
                        height: width
                        color: "#70777777"
                        opacity: model.enabled ? 1 : 0.4
                        Image {
                            anchors.fill: parent
                            source: iconPath
                        }
                    }

                    Label {
                        id: providerLabel
                        anchors {
                            left: icon.right
                            right: parent.right
                            margins: Theme.paddingMedium
                            verticalCenter: icon.verticalCenter
                            verticalCenterOffset: implicitHeight / -2 - Theme.paddingSmall
                        }
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                        opacity: model.enabled ? 1 : 0.4
                        text: provider
                    }

                    ContactPresenceIndicator {
                        id: presenceIndicator
                        anchors {
                            left: icon.right
                            leftMargin: Theme.paddingMedium
                            verticalCenter: icon.verticalCenter
                        }

                        presenceState: model.presenceState
                    }

                    Label {
                        id: accountLabel
                        anchors {
                            left: icon.right
                            right: parent.right
                            margins: Theme.paddingMedium
                            verticalCenter: icon.verticalCenter
                            verticalCenterOffset: implicitHeight / 2 + Theme.paddingSmall / 2
                        }
                        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        opacity: model.enabled ? 1 : 0.4
                        text: accountName
                    }

                    onClicked: showMenu()
                }
            }
        }
    }
}
