import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.dbus 1.0
import MeeGo.QOfono 0.2
import "common/common.js" as CommonJs
import "contactcard/contactcardmodelfactory.js" as ModelFactory
import "contactcard"

SilicaFlickable {
    id: root

    property Person contact
    property string activeDetail
    property bool readOnly
    property bool hidePhoneActions: ofonoManager.modems.length < 1
    property bool disablePhoneActions: !ofonoSimManager.present

    signal contactModified

    property Item _activeDetailItem
    property QtObject _messagesInterface
    property bool _handlingClick

    function refreshDetails() {
        CommonJs.init(Person)
        ModelFactory.init(CommonJs)

        ModelFactory.getContactCardDetailsModel(details.model, contact)
    }

    function _asyncRefresh() {
        if (contact.complete) {
            contact.completeChanged.disconnect(_asyncRefresh)
            refreshDetails()
        }
    }

    function _updateAvatarUrl(avatarUrl) {
        contact.avatarPath = avatarUrl
        contactModified()
    }

    onContactChanged: {
        if (contact) {
            if (contact.complete) {
                refreshDetails()
            } else {
                contact.completeChanged.connect(_asyncRefresh)
            }
        } else {
            details.model.clear()
        }
    }

    Connections {
        target: contact
        onDataChanged: refreshDetails()
    }

    on_ActiveDetailItemChanged: activeDetail = (_activeDetailItem ? _activeDetailItem.detailValue : '')

    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height
    contentHeight: header.height + Theme.paddingSmall + details.height + Theme.paddingLarge

    ContactHeader {
        id: header

        width: parent.width
        contact: root.contact
        readOnly: root.readOnly

        onAvatarFromGallery: {
            // Life-cycle of avatar picker needs to follow contact card's life-cycle.
            // Cropping is async operation and might take more than the page pop transition.
            // AvatarPickerPage destoyes itself once finished.
            var pickerPageComponent = Qt.createComponent('AvatarPickerPage.qml')
            if (pickerPageComponent.status == Component.Ready) {
                var picker = pickerPageComponent.createObject(root);
                picker.avatarUrlChanged.connect(function(avatarUrl) {
                    _updateAvatarUrl(avatarUrl)
                    picker.destroy()
                })
                pageStack.push(picker)
            } else {
                console.log('Unable to load avatar picker - error:', pickerPageComponent.errorString())
            }
        }

        onAvatarFromCamera: {
            // TODO
        }

        onContactModified: root.contactModified()
    }

    ListView {
        id: details
        interactive: false
        spacing: Math.round(Theme.itemSizeSmall / 2)

        width: parent.width
        y: header.height + Theme.paddingLarge

        onContentHeightChanged: height = contentHeight

        property real _activationProgress: 1
        property QtObject activationAnimation: NumberAnimation {
            target: details
            property: '_activationProgress'
            to: 1
            duration: 200
            easing.type: Easing.InOutQuad
        }

        model: ListModel {}

        delegate: ContactDetailDelegate {
            id: detailDelegate
            active: _activeDetailItem === detailDelegate
            width: ListView.view.width

            detailType: detailsType
            detailTypeValue: detailsLabel
            detailValue: detailsValue
            detailData: detailsData
            hidePhoneActions: root.hidePhoneActions
            disablePhoneActions: root.disablePhoneActions

            activationProgress: details._activationProgress

            Component.onCompleted: {
                if ((activeDetail === "" && index === 0) ||
                    (activeDetail === detailValue) ||
                    (Person.minimizePhoneNumber(activeDetail) === Person.minimizePhoneNumber(detailValue))) {
                    _activeDetailItem = detailDelegate
                }
            }

            onContactDetailClicked: {
                if (_activeDetailItem != detailDelegate) {
                    // Need to suppress onActiveDetailChanged handler. If there are two details with
                    // the same value the wrong one might be activated otherwise.
                    _handlingClick = true
                    _activeDetailItem = detailDelegate
                    details._activationProgress = 0
                    details.activationAnimation.start()
                    _handlingClick = false
                }
            }

            onCallClicked: {
                console.log("Call number: " + number + ", connection: " + connection)
                voicecall.dial(number)
            }

            onSmsClicked: {
                console.log("SMS number: " + number + ", connection: " + connection)
                if (!_messagesInterface) {
                    _messagesInterface = Qt.createQmlObject('import "common"; MessagesInterface { }', root)
                    if (!_messagesInterface)
                        console.log("ContactCardPage: Failed creating MessagesInterface instance")
                }
                _messagesInterface.startSMS(number)
            }

            onEmailClicked: {
                pageStack.push(Qt.resolvedUrl("EmailComposer.qml"), { emailTo: email })
            }

            onImClicked: {
                console.log("IMAddress: " + localUid + ":" + remoteUid)
                if (!_messagesInterface) {
                    _messagesInterface = Qt.createQmlObject('import "common"; MessagesInterface { }', root)
                    if (!_messagesInterface)
                        console.log("ContactCardPage: Failed creating MessagesInterface instance")
                }
                _messagesInterface.startConversation(localUid, remoteUid)
            }

            onAddressClicked: {
                console.log("Address: " + address)
                mapsInterface.openAddress(addressParts["street"], addressParts["city"],
                                          addressParts["region"], addressParts["zipcode"],
                                          addressParts["country"])
            }

            onWebsiteClicked: {
                var schemeSeparatorIndex =  url.indexOf(':')
                if (schemeSeparatorIndex <= 0 || schemeSeparatorIndex > 'https'.length) {
                    // Assume http
                    url = 'http://' + url
                }
                console.log("Website: " + url)
                Qt.openUrlExternally(url)
            }

            onDateClicked: {
                // Rather than showing the contact's actual birth or anniversary date in the calendar,
                // show the next occurrence of the anniversary of the recorded date
                var now = new Date()
                var nextDate = new Date(now.getFullYear(), date.getMonth(), date.getDate())
                if (new Date(now.getFullYear(), now.getMonth(), now.getDate()) > nextDate) {
                    nextDate.setFullYear(nextDate.getFullYear() + 1)
                }
                var formatted = Qt.formatDate(nextDate, Qt.ISODate)
                console.log("Date: " + formatted)
                calendarInterface.showDate(formatted)
            }

            DBusInterface {
                id: calendarInterface

                destination: "com.jolla.calendar.ui"
                path: "/com/jolla/calendar/ui"
                iface: "com.jolla.calendar.ui"

                function showDate(date) {
                    call('viewDate', date)
                }
            }

            Connections {
                target: root
                onActiveDetailChanged: {
                    if (!root._handlingClick && root.activeDetail == detailValue) {
                        _activeDetailItem = detailDelegate
                    }
                }
            }
        }
    }
    DBusInterface {
        id: voicecall
        destination: "com.jolla.voicecall.ui"
        path: "/"
        iface: "com.jolla.voicecall.ui"
        function dial(number) {
            call('dial', number)
        }
    }
    DBusInterface {
        id: mapsInterface
        destination: "org.sailfishos.maps"
        path: "/"
        iface: "org.sailfishos.maps"
        function openAddress(street, city, region, zipcode, country) {
            call('openAddress', [street, city, region, zipcode, country])
        }
    }

    OfonoManager {
        id: ofonoManager
    }

    OfonoSimManager {
        id: ofonoSimManager
        modemPath: ofonoManager.defaultModem
    }

    VerticalScrollDecorator {}
}
