import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0 as SailfishContacts
import org.nemomobile.contacts 1.0

Page {
    id: contactPage
    allowedOrientations: Orientation.All

    property alias contact: contactCard.contact
    property var peopleModel

    property alias activeDetail: contactCard.activeDetail
    property bool exitAfterSave: true

    property var _peopleModel: peopleModel || SailfishContacts.ContactModelCache.unfilteredModel()

    function matchContact() {
        if (_peopleModel.populated && contactCard.contact && contactCard.contact.id === 0) {
            var person
            var detail
            if (contactCard.contact.phoneDetails.length) {
                detail = contactCard.contact.phoneDetails[0].number
                person = _peopleModel.personByPhoneNumber(detail, true)
            } else if (contactCard.contact.emailDetails.length) {
                detail = contactCard.contact.emailDetails[0].address
                person = _peopleModel.personByEmailAddress(detail, true)
            } else if (contactCard.contact.accountDetails.length) {
                detail = contactCard.contact.accountDetails[0].accountUri
                person = _peopleModel.personByOnlineAccount(contactCard.contact.accountDetails[0].accountPath, detail, true)
            }
            if (person) {
                contactCard.contact = person
                contactCard.activeDetail = detail
            }
        }
    }

    function _popPage() {
        // Pop back to the contact card, or its predecessor.
        var target = exitAfterSave ? pageStack.previousPage(contactPage) : contactPage
        pageStack.pop(target)
    }

    Component.onCompleted: {
        matchContact()
    }

    Connections {
        target: _peopleModel
        onPopulatedChanged: matchContact()
    }

    ContactCard {
        id: contactCard

        anchors.fill: parent

        ContactCardPullDownMenu {
            page: contactPage
            _peopleModel: contactPage._peopleModel
            contact: contactCard.contact

            onTemporaryContactLinked: {
                contactCard.activeDetail = detail

                // Delay pagestack pop; popping immediately after contact selection+saving causes objects
                // to be destroyed unexpectedly.
                delayedPagePop.start()
            }

            MenuItem {
                //: Save contact
                //% "Save"
                text: qsTrId("components_contacts-me-save")
                visible: contact === null || !contact.id

                onClicked: {
                    var editorProperties = {
                        "subject": contact,
                        "acceptDestination": saveBusyComponent
                    }
                    pageStack.animatorPush(Qt.resolvedUrl("ContactEditorDialog.qml"), editorProperties)
                }
            }
        }
    }

    Component {
        id: saveBusyComponent

        Page {
            onStatusChanged: {
                if (status === PageStatus.Active) {
                    contactPage._popPage()
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                size: BusyIndicatorSize.Large
            }
        }
    }

    Timer {
        id: delayedPagePop

        interval: 0
        onTriggered: contactPage._popPage()
    }
}
