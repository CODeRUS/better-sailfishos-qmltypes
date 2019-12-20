import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

ContactSelectPage {
    property Person temporaryContact
    property Person selectedContact

    signal detailAppended(var detail)

    function appendDetail() {
        var detail
        var details

        if (temporaryContact.phoneDetails.length) {
            detail = temporaryContact.phoneDetails[0].number

            details = selectedContact.phoneDetails
            details.push({
                             'number': detail,
                             'type': Person.PhoneNumberType,
                             'index': -1
                         })
            selectedContact.phoneDetails = details
        } else if (temporaryContact.emailDetails.length) {
            detail = temporaryContact.emailDetails[0].address

            details = selectedContact.emailDetails
            details.push({
                             'address': detail,
                             'type': Person.EmailAddressType,
                             'index': -1
                         })
            details.push(detail)
            selectedContact.emailDetails = details
        } else if (temporaryContact.accountDetails.length) {
            detail = temporaryContact.accountDetails[0].accountUri

            details = selectedContact.accountDetails
            details.push({
                             'accountUri': detail,
                             'type': Person.OnlineAccountType,
                             'index': -1
                         })
            details.push(detail)
            selectedContact.accountDetails = details
        }

        pageStack.animatorReplace(Qt.resolvedUrl("ContactCardPostSavePage.qml"),
                                  {"peopleModel": allContactsModel})
        allContactsModel.savePerson(selectedContact)
        temporaryContact = selectedContact
        detailAppended(detail)
    }

    function appendDetailAsync() {
        if (selectedContact.complete) {
            selectedContact.completeChanged.disconnect(appendDetailAsync)
            appendDetail()
        }
    }

    onContactClicked: {
        selectedContact = contact
        if (selectedContact.complete) {
            appendDetail()
        } else {
            selectedContact.completeChanged.connect(appendDetailAsync)
        }
    }
}

