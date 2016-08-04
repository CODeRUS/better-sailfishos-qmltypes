import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.dbus 1.0
import org.freedesktop.contextkit 1.0
import "common/common.js" as CommonJs
import "contactcard/contactcardmodelfactory.js" as ModelFactory
import "contactcard"

SilicaFlickable {
    id: root

    property Person contact
    property string activeDetail
    property bool readOnly
    property bool hidePhoneActions: cellular1Status.disabled && cellular2Status.disabled
    property bool disablePhoneActions: !cellular1Status.registered && !cellular2Status.registered

    signal contactModified

    property Item _activeDetailItem
    property QtObject _messagesInterface
    property bool _handlingClick
    property bool _repositionOnResize

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

    function startPhoneCall(number, modemPath) {
        if (modemPath !== undefined && modemPath !== "") {
            voicecall.dialViaModem(modemPath, number)
        } else {
            voicecall.dial(number)
        }
    }

    function startSms(number) {
        messagesInterface().startSMS(number)
    }

    function startInstantMessage(localUid, remoteUid) {
        messagesInterface().startConversation(localUid, remoteUid)
    }

    function messagesInterface() {
        if (!_messagesInterface) {
            _messagesInterface = Qt.createQmlObject('import "common"; MessagesInterface { }', root)
            if (!_messagesInterface)
                console.log("ContactCardPage: Failed creating MessagesInterface instance")
        }
        return _messagesInterface
    }

    function activate(delegate) {
        if (_activeDetailItem != delegate) {
            // Need to suppress onActiveDetailChanged handler. If there are two details with
            // the same value the wrong one might be activated otherwise.
            _handlingClick = true
            _activeDetailItem = delegate
            details._activationProgress = 0
            details.activationAnimation.start()
            _handlingClick = false
        }
    }

    Timer {
        id: repositionTimer
        interval: 0
        onTriggered: {
            // We may need to reposition to make the active item visible
            var detailY = root.mapFromItem(root._activeDetailItem, 0, 0).y
            var detailEndY = detailY + Math.min(root._activeDetailItem.height, root.height)
            if (detailY < 0) {
                repositionAnimation.to = root.contentY + detailY
                repositionAnimation.restart()
            } else if (detailEndY > root.height) {
                repositionAnimation.to = root.contentY + (detailEndY - root.height)
                repositionAnimation.restart()
            }
        }
    }

    NumberAnimation {
        id: repositionAnimation
        target: root
        property: "contentY"
        easing.type: Easing.InOutQuad
        duration: 200
    }

    Connections {
        target: root._repositionOnResize ? root._activeDetailItem : null
        onHeightChanged: {
            repositionTimer.restart()
            root._repositionOnResize = false
        }
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

        // This list view should not move to accommodate the context menu
        property int __silica_hidden_flickable

        property real _activationProgress: 1
        property QtObject activationAnimation: NumberAnimation {
            target: details
            property: '_activationProgress'
            to: 1
            duration: 200
            easing.type: Easing.InOutQuad

            onRunningChanged: {
                if (!running) {
                    repositionTimer.restart()
                }
            }
        }

        model: ListModel {}

        delegate: Loader {
            width: parent.width
            sourceComponent: detailsType == "activity" ? activityDelegate : detailDelegate

            Component {
                id: detailDelegate

                ContactDetailDelegate {
                    id: detailDelegate

                    active: _activeDetailItem === detailDelegate
                    width: details.width

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

                    onContactDetailClicked: root.activate(detailDelegate)

                    onCallClicked: {
                        console.log("Call number: " + number + ", connection: " + connection + ", modem: " + modemPath)
                        root.startPhoneCall(number, modemPath)
                    }

                    onSmsClicked: {
                        console.log("SMS number: " + number + ", connection: " + connection)
                        root.startSms(number)
                    }

                    onEmailClicked: {
                        pageStack.push(Qt.resolvedUrl("EmailComposer.qml"), { emailTo: email })
                    }

                    onImClicked: {
                        console.log("IMAddress: " + localUid + ":" + remoteUid)
                        root.startInstantMessage(localUid, remoteUid)
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

            Component {
                id: activityDelegate

                ExpandingDelegate {
                    id: activityDelegate

                    active: _activeDetailItem === activityDelegate
                    width: details.width

                    detailTypeValue: detailsLabel
                    detailValue: detailsValue

                    activationProgress: details._activationProgress

                    onContactDetailClicked: root.activate(activityDelegate)

                    onActiveChanged: {
                        if (active && !loader.sourceComponent) {
                            loader.sourceComponent = activityListComponent
                        }
                    }

                    Component {
                        id: activityListComponent

                        Item {
                            width: parent.width
                            height: Math.max(activityList.height + Math.max(showMore.height, seeAll.height), placeholder.height)

                            ContactActivityList {
                                id: activityList

                                property bool reduced: true
                                property int reducedLimit: 3

                                // This list view should not move to accommodate the context menu
                                property int __silica_hidden_flickable

                                function updateHeight() {
                                    // Once we have content, the last item is suppressed if it indicates more items exist
                                    var h = contentHeight - (hasMore && !reduced ? Theme.itemSizeMedium : 0)

                                    // When reduced, items after the first three are not visible
                                    var maxItems = reduced ? reducedLimit : limit
                                    if (count > maxItems) {
                                        h -= ((count - maxItems) * Theme.itemSizeMedium)
                                    }

                                    height = h
                                }

                                contact: root.contact
                                limit: 15
                                interactive: false
                                clip: true

                                // Until the model is resolved, assume we will have 3 items
                                height: reducedLimit * Theme.itemSizeMedium
                                onContentHeightChanged: updateHeight()
                                onReducedChanged: updateHeight()

                                onStartPhoneCall: root.startPhoneCall(number, modemPath)
                                onStartSms: root.startSms(number)
                                onStartInstantMessage: root.startInstantMessage(localUid, remoteUid)
                            }

                            BackgroundItem {
                                id: showMore

                                anchors.top: activityList.bottom
                                height: visible ? Theme.itemSizeSmall : 0
                                visible: activityList.ready && activityList.reduced && activityList.count > activityList.reducedLimit

                                Label {
                                    id: showMoreLabel

                                    anchors {
                                        left: parent.left
                                        leftMargin: activityList.leftMargin
                                        verticalCenter: parent.verticalCenter
                                    }

                                    //% "Show more"
                                    //: Should match the translation for sailfish-components-lipstick-la-show-more
                                    text: qsTrId("components_contacts-la-show_more")
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    font.italic: true
                                    color: showMore.down ? Theme.highlightColor : Theme.primaryColor
                                }
                                Image {
                                    anchors {
                                        left: showMoreLabel.right
                                        leftMargin: Theme.paddingMedium
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "image://theme/icon-lock-more?" + (showMore.down ? Theme.highlightColor : Theme.primaryColor)
                                    width: Theme.iconSizeMedium * 0.7
                                    height: width
                                    sourceSize.width: width
                                }

                                onClicked: {
                                    activityList.reduced = false
                                    root._repositionOnResize = true
                                }
                            }

                            BackgroundItem {
                                id: seeAll

                                anchors.top: activityList.bottom
                                height: visible ? Theme.itemSizeSmall : 0
                                visible: activityList.ready && !activityList.reduced && activityList.hasMore

                                Image {
                                    id: rightIcon

                                    anchors {
                                        right: parent.right
                                        rightMargin: Theme.paddingMedium
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: "image://theme/icon-m-right?" + (seeAll.down ? Theme.highlightColor : Theme.primaryColor)
                                }
                                Label {
                                    anchors {
                                        right: rightIcon.left
                                        rightMargin: Theme.paddingMedium
                                        verticalCenter: parent.verticalCenter
                                    }
                                    //% "See all activity"
                                    text: qsTrId("components_contacts-la-see_all_activity")
                                    color: seeAll.down ? Theme.highlightColor : Theme.primaryColor
                                }

                                onClicked: {
                                    pageStack.pushAttached(activityPageComponent, {}, PageStackAction.Immediate)
                                    pageStack.navigateForward()
                                }

                                Component {
                                    id: activityPageComponent

                                    ContactActivityPage {
                                        contact: root.contact

                                        onStartPhoneCall: root.startPhoneCall(number, modemPath)
                                        onStartSms: root.startSms(number)
                                        onStartInstantMessage: root.startInstantMessage(localUid, remoteUid)
                                    }
                                }
                            }

                            Item {
                                id: placeholder
                                height: Theme.itemSizeMedium
                                width: parent.width
                                visible: activityList.ready && activityList.count === 0

                                Label {
                                    anchors.centerIn: parent
                                    //% "No communications activity"
                                    text: qsTrId("components_contacts-la-no_activity")
                                    opacity: 0.6
                                }
                            }
                        }
                    }

                    expandingContent: [
                        Item {
                            width: activityDelegate.width
                            height: loader.item ? loader.item.height : Theme.itemSizeMedium

                            Loader {
                                id: loader
                                anchors.fill: parent
                            }
                            BusyIndicator {
                                anchors.centerIn: parent
                                running: loader.status != Loader.Ready
                                visible: running
                            }
                        }
                    ]
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

        function dialViaModem(modemPath, number) {
            call('dialViaModem', [ modemPath, number ])
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
    DBusInterface {
        id: calendarInterface

        destination: "com.jolla.calendar.ui"
        path: "/com/jolla/calendar/ui"
        iface: "com.jolla.calendar.ui"

        function showDate(date) {
            call('viewDate', date)
        }
    }

    ContextProperty {
        id: cellular1Status
        property bool disabled: value == "disabled" || value == undefined
        property bool registered: value == "registered" || value == "roaming"
        key: "Cellular.Status"
    }
    ContextProperty {
        id: cellular2Status
        property bool disabled: value == "disabled" || value == undefined
        property bool registered: value == "registered" || value == "roaming"
        key: "Cellular_1.Status"
    }

    VerticalScrollDecorator {}
}
