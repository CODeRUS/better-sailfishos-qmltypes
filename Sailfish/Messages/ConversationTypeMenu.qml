import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Messages 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.contacts 1.0

ContextMenu {
    id: menu

    property var people
    onPeopleChanged: refresh()

    property string localUid
    property string remoteUid: {
        if (!people || people.length === 0) {
            return ""
        }
        var phoneDetails = people[0].phoneDetails
        if (phoneDetails.length > 0) {
            return phoneDetails[0].minimizedNumber
        }
        return ""
    }

    property alias model: typesModel
    property alias count: typesModel.count
    property bool isMenuLandscape: isLandscape

    signal closeKeyboard()

    width: parent ? parent.width : Screen.width

    // TODO: remove once Qt.inputMethod.animating has been implemented JB#15726
    property Item lateParentItem
    property bool noKeyboard: lateParentItem && ((isMenuLandscape && pageStack.width === Screen.width) ||
                                                 (!isMenuLandscape && pageStack.height === Screen.height))
    onNoKeyboardChanged: {
        if (noKeyboard) {
            open(lateParentItem)
            lateParentItem = null
        }
    }

    onIsMenuLandscapeChanged: {
        if (isMenuLandscape && menu.active) {
            closeKeyboard()
        }
    }

    function openMenu(parentItem) {
        var currentIndex = typesModel.currentIndex()
        menu._setHighlightedItem(itemRepeater.itemAt(currentIndex))

        // if large number of types push stand-alone selection page
        if (count > 5) {
            pageStack.animatorPush("TypeMenuPage.qml", {"typesModel": model, "menu": menu, "currentIndex": currentIndex })

        // close keyboard if necessary
        } else if (Qt.inputMethod.visible && isMenuLandscape) {
            closeKeyboard()
            lateParentItem = parentItem
        } else {
            open(parentItem)
        }
    }

    Repeater {
        id: itemRepeater
        model: menu.model
        MenuItem {
            id: menuItem
            TypeMenuItem {
                color: highlighted ? Theme.primaryColor : Theme.highlightColor
                centerAlign: true
                font: menuItem.font
            }
        }
    }

    function refresh() {
        typesModel.refresh(people)
    }

    ListModel {
        id: typesModel

        function currentIndex() {
            var remotePhone = Person.minimizePhoneNumber(remoteUid)
            for (var i = 0; i < typesModel.count; i++) {
                var object = typesModel.get(i)
                if ((localUid.length === 0 || object.localUid === localUid) && (object.remoteUid === remoteUid
                        || (remotePhone.length > 0 && Person.minimizePhoneNumber(object.remoteUid) === remotePhone)))
                    return i
            }
            return -1
        }

        function refresh(people) {
            clear()
            ContactsUtil.init()

            if (people.length === 1)
                _refreshOne(people[0])
            else
                _refreshMany(people)
        }

        // With one person, show all accounts and all phone numbers
        function _refreshOne(person) {
            var i
            if (MessageUtils.hasModem) {
                var numbers = Person.removeDuplicatePhoneNumbers(person.phoneDetails)
                for (i = 0; i < numbers.length; i++) {
                    var phoneNumberText = ""
                    // If there is more than one phone number, display it underneath the primary label
                    if (numbers.length > 1) {
                        var detail = numbers[i]
                        phoneNumberText = ContactsUtil.getNameForDetailSubType(detail.type, detail.subtypes, detail.label, true) + "  " + detail.number
                    }

                    append({
                        "display": MessageUtils.telepathyAccounts.displayName(MessageUtils.telepathyAccounts.ringAccountPath),
                        "phoneNumberText": phoneNumberText,
                        "localUid": MessageUtils.telepathyAccounts.ringAccountPath,
                        "remoteUid": numbers[i].number
                    })
                }
            }

            var accounts = Person.removeDuplicateOnlineAccounts(person.accountDetails)
            for (i = 0; i < accounts.length; i++) {
                if (accounts[i].accountPath.length > 0) {
                    append({
                        "display": accounts[i].serviceProviderDisplayName ? accounts[i].serviceProviderDisplayName : MessageUtils.telepathyAccounts.displayName(accounts[i].accountPath),
                        "phoneNumberText": "",
                        "localUid": accounts[i].accountPath,
                        "remoteUid": accounts[i].accountUri
                    })
                }
            }
        }

        // With many people, show only *local* accounts that are shared by all people
        function _refreshMany(people) {
            var paths = { }
            var account

            for (var i = 0; i < people.length; i++) {
                if (MessageUtils.hasModem) {
                    if (people[i].phoneDetails.length) {
                        account = MessageUtils.telepathyAccounts.ringAccountPath
                        if (paths[account] == undefined)
                            paths[account] = 1
                        else
                            paths[account]++
                    }
                }

                var accounts = people[i].accountDetails
                for (var j = 0; j < accounts.length; j++) {
                    account = accounts[j].accountPath
                    if (account) {
                        if (paths[account] == undefined)
                            paths[account] = 1
                        else
                            paths[account]++
                    }
                }
            }

            for (account in paths) {
                if (paths[account] !== people.length)
                    continue

                // Multiple remote UIDs aren't handled yet
                append({
                    "display": MessageUtils.telepathyAccounts.displayName(account),
                    "phoneNumberText": "",
                    "localUid": account,
                    "remoteUid": ""
                })
            }
        }
    }
}

