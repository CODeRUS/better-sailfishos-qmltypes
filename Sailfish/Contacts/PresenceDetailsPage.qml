import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import "common/common.js" as CommonJs

Page {
    id: presencePage

    property var globalPresenceState
    property ListModel presenceModel: ListModel {}

    property Component presenceSwitchBar: presenceSwitchBarComponent

    property bool _presenceAvailable

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
        var i; var j; var account; var available

        var accounts = getPresenceAccounts()

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

        available = false
        for (i = 0; i < accounts.length; ++i) {
            account = accounts[i]
            if (account.enabled) {
                available = true
            }

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

        _presenceAvailable = available
    }

    ContactPresenceUpdate {
        id: presenceUpdate
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator {}

        ViewPlaceholder {
            id: placeholder

            enabled: !presencePage._presenceAvailable
            //: Displayed when there are no presence accounts
            //% "No accounts available with presence functionality"
            text: qsTrId("components_contacts-la-no_presence")
            //: Informs the user to configure an account in Settings | Accounts
            //% "You can add or modify accounts in Settings | Accounts"
            hintText: qsTrId("components_contacts-la-no_presence_hint")
        }

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: header
                //% "Presence"
                title: qsTrId("components_contacts-he-presence_details")
            }

            Loader {
                sourceComponent: presencePage.presenceSwitchBar
                visible: presencePage._presenceAvailable
            }

            SectionHeader {
                //: List of services with presence that the global switches affect
                //% "Controlled services"
                text: qsTrId("components_contacts-la-controlled_services")
                visible: presencePage._presenceAvailable
            }

            Repeater {
                model: presenceModel

                delegate: ListItem {
                    property var path: presenceModel.get(index).path
                    width: parent.width
                    contentHeight: icon.height
                    visible: model.enabled
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
                                    text: CommonJs.presenceDescription(presence)
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
                        text: accountName
                    }

                    onClicked: showMenu()
                }
            }
        }
    }

    Component {
        id: presenceSwitchBarComponent

        GlobalPresenceSwitchBar {
            width: presencePage.width
            globalPresenceState: presencePage.globalPresenceState
        }
    }
}
