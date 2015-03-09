import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Dialog {
    id: root

    property string firstNameOrDisplayName

    property Person _selfPerson: peopleModel.selfPerson()
    property var _birthday: _selfPerson != null && _selfPerson.complete ? _selfPerson.birthday : undefined

    function _saveContactDetails() {
        var index = 0

        if (firstNameField.text.trim() !== "") {
            _selfPerson.firstName = firstNameField.text.trim()
        }
        if (firstNameField.text.trim() !== "") {
            _selfPerson.lastName = lastNameField.text.trim()
        }
        var myEmail = emailField.text.trim()
        if (myEmail !== "") {
            var emails = _selfPerson.emailDetails
            emails.push({
                'type': Person.EmailAddressType,
                'address': myEmail,
                'index': -1
            })
            _selfPerson.emailDetails = emails
        }
        var myPhone = phoneField.text.trim()
        if (myPhone !== "") {
            var numbers = _selfPerson.phoneDetails
            numbers.push({
                'type': Person.PhoneNumberType,
                'number': myPhone,
                'index': -1
            })
            _selfPerson.phoneDetails = numbers
        }
        if (_birthday && _birthday.toString() !== "Invalid Date") {
            _selfPerson.birthday = _birthday
        }

        if (!peopleModel.savePerson(_selfPerson)) {
            console.log("Start-up wizard: unable to save my contact details!")
        }
    }

    function _selectSelfPersonMultiValueField(details, property) {
        if (details.length === 0) {
            return ""
        }
        // We add our values last, with no label
        for (var i = details.length - 1; i >= 0; --i) {
            var detail = details[i]
            if (!detail.label || detail.label === Person.NoLabel) {
                return detail[property]
            }
        }
        // No detail matches, just return the last one
        return details[details.length - 1][property]
    }

    onDone: {
        if (result === DialogResult.Accepted) {
            _saveContactDetails()
            if (firstNameField.text.trim() !== "" || firstNameField.text.trim() !== "") {
                // only use if first/last is set, else displayLabel will be "(Unnamed)"
                root.firstNameOrDisplayName = _selfPerson.displayLabel
            }
        }
    }

    PeopleModel {
        id: peopleModel
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                id: dialogHeader
                dialog: root
                acceptText: (firstNameField.text === ""
                        && lastNameField.text === ""
                        && emailField.text === ""
                        && phoneField.text === ""
                        && (!_birthday || _birthday.toString() === "Invalid Date"))
                         //: Button to skip the current step in the start-up wizard
                         //% "Skip"
                       ? qsTrId("startupwizard-la-skip")
                         //: Button to save the user's personal contact card details using the currently entered details
                         //% "Save"
                       : qsTrId("startupwizard-la-save_contact_card")
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.WordWrap
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeExtraLarge
                }
                color: Theme.highlightColor

                //: Heading for page that allows user to fill in his/her personal contact details for the address book
                //% "My info"
                text: qsTrId("startupwizard-he-my_info")
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.rgba(Theme.highlightColor, 0.9)

                //: Description for page that allows user to fill in his/her personal contact details for the address book
                //% "This information will be stored only to your device."
                text: qsTrId("startupwizard-la-my_info")
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.rgba(Theme.highlightColor, 0.9)
                visible: text != ""

                text: {
                    //: Hint text for changing keyboard layout on spacebar long press, translate only for non-latin languages
                    //% ""
                    var translation = qsTrId("startupwizard-la-vkb_layout_change_hint")
                    return (translation === "startupwizard-la-vkb_layout_change_hint")
                            ? ""
                            : translation
                }
            }

            TextField {
                id: firstNameField
                width: parent.width

                //% "First name"
                label: qsTrId("startupwizard-la-first_name")

                //% "Enter first name"
                placeholderText: qsTrId("startupwizard-ph-first_name")

                text: root._selfPerson != null ? root._selfPerson.firstName : ""

                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: lastNameField.focus = true
            }

            TextField {
                id: lastNameField
                width: parent.width

                //% "Last name"
                label: qsTrId("startupwizard-la-last_name")

                //% "Enter last name"
                placeholderText: qsTrId("startupwizard-ph-last_name")

                text: root._selfPerson != null ? root._selfPerson.lastName : ""

                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: emailField.focus = true
            }

            TextField {
                id: emailField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly

                //% "Email address"
                label: qsTrId("startupwizard-la-email")

                //% "Enter email address"
                placeholderText: qsTrId("startupwizard-ph-email")

                text: root._selfPerson != null
                      ? root._selectSelfPersonMultiValueField(root._selfPerson.emailDetails, 'address')
                      : ""

                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: phoneField.focus = true
            }

            TextField {
                id: phoneField
                width: parent.width
                inputMethodHints: Qt.ImhDialableCharactersOnly

                //% "Phone number"
                label: qsTrId("startupwizard-la-phone")

                //% "Enter phone number"
                placeholderText: qsTrId("startupwizard-ph-phone")

                text: root._selfPerson != null
                      ? root._selectSelfPersonMultiValueField(root._selfPerson.phoneDetails, 'number')
                      : ""

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }

            ValueButton {
                id: birthdayButton

                //: Allows birthday to be selected
                //% "Birthday:"
                label: qsTrId("startupwizard-la-birthday")

                value: root._birthday != null && root._birthday.toString() !== "Invalid Date"
                       ? Format.formatDate(root._birthday, Format.DateLong)
                         //% "Select your birthday"
                       : qsTrId("startupwizard-bt-select_birthday")

                onClicked: {
                    root.focus = true
                    var dialog = pageStack.push(datePickerComponent, { date: root._birthday, _showYearSelectionFirst: true })
                    dialog.accepted.connect(function() {
                        root._birthday = dialog.date
                        birthdayButton.value = Format.formatDate(root._birthday, Format.DateLong)
                    })
                }
            }
        }
    }

    Component {
        id: datePickerComponent
        DatePickerDialog {}
    }
}
