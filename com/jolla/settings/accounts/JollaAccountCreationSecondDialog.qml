import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.contacts 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0

Dialog {
    id: root

    property AccountManager accountManager

    property string username
    property string password
    property bool createAccountOnAccept: true
    property string acceptText
    property string cancelText

    property alias firstName: firstNameField.text
    property alias lastName: lastNameField.text
    property alias email: emailField.text
    property alias phoneNumber: phoneField.text
    property alias countryCode: countryButton.countryCode
    property alias countryName: countryButton.countryName
    property string languageLocale: languageModel.locale(languageModel.currentIndex)
    property var birthday: _selfPerson != null && _selfPerson.complete ? _selfPerson.birthday : undefined

    // Required for compatibility with jolla-store implementation.
    property Provider accountProvider
    property Item creationBusyDialog
    acceptDestination: creationBusyDialog
    onStatusChanged: {
        if (status == PageStatus.Inactive) {
            root.focus = true
        }
    }

    signal accountCreated(int newAccountId)
    signal accountCreationTypedError(int errorCode, string errorMessage)

    function createAccount() {
        accountFactory.createNewJollaAccount(
                    username,
                    password,
                    emailField.text,
                    firstNameField.text,
                    lastNameField.text,
                    birthday,
                    phoneField.text,
                    countryCode,
                    languageLocale,
                    "Jolla", "Jolla")
    }


    // --- end public api ---

    property bool checkMandatoryFields
    property Person _selfPerson: peopleModel.selfPerson()

    // Check that the email is basically in the format "blah@blah.com[...]", without any whitespace.
    // We don't want the regex to be too strict because a wide variety of characters are acceptable in an email address.
    property var _emailRegex: /^\S+@\S+\.\S+$/

    function _saveContactDetails() {
        var index = 0

        if (firstName.trim() !== "") {
            _selfPerson.firstName = firstName.trim()
        }
        if (lastName.trim() !== "") {
            _selfPerson.lastName = lastName.trim()
        }
        var myEmail = email.trim()
        if (myEmail !== "") {
            var emails = _selfPerson.emailDetails
            emails.push({
                'type': Person.EmailAddressType,
                'address': myEmail,
                'index': -1
            })
            _selfPerson.emailDetails = emails
        }
        var myPhone = phoneNumber.trim()
        if (myPhone !== "") {
            var numbers = _selfPerson.phoneDetails
            numbers.push({
                'type': Person.PhoneNumberType,
                'number': myPhone,
                'index': -1
            })
            _selfPerson.phoneDetails = numbers
        }
        if (birthday && !isNaN(birthday.getTime())) {
            _selfPerson.birthday = birthday
        }
        if (!peopleModel.savePerson(_selfPerson)) {
            console.log("Unable to save self contact details!")
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

    // note phone field is optional
    canAccept: firstNameField.text !== ""
               && lastNameField.text !== ""
               && !emailField.errorHighlight
               && countryCode !== ""
               && languageLocale !== ""
               && (birthday != null && !isNaN(birthday.getTime()))

    onAccepted: {
        _saveContactDetails()
        if (createAccountOnAccept) {
            createAccount()
        }
    }

    onAcceptPendingChanged: {
        if (acceptPending === true) {
            checkMandatoryFields = true
        }
    }

    // Required for compatibility with jolla-store implementation.
    // It expects creationBusyDialog (an instance of AccountCreationBusyDialog) to be notified of
    // the account creation result.
    onAccountCreated: {
        if (creationBusyDialog != null) {
            creationBusyDialog.accountCreationSucceeded(newAccountId)
        }
    }
    onAccountCreationTypedError: {
        if (creationBusyDialog != null) {
            creationBusyDialog.accountCreationFailed(errorCode, errorMessage)
        }
    }

    PeopleModel {
        id: peopleModel
    }

    AccountFactory {
        id: accountFactory

        onError: {
            console.log("JollaAccountCreationDialog error:", message)
            root.accountCreationTypedError(errorCode, message)
        }

        onSuccess: {
            root.accountCreated(newAccountId)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                dialog: root
                acceptText: root.acceptText.length ? root.acceptText : defaultAcceptText
                cancelText: root.cancelText.length ? root.cancelText : defaultCancelText

                //: Description for page that requests user's name, email and other details in order to create a Jolla account
                //% "Almost done, we just need a few more details"
                title: qsTrId("settings_accounts-he-almost_done")

                // Ensure checkMandatoryFields is set if 'accept' is tapped and some fields
                // are not valid
                Item {
                    id: headerChild
                    Connections {
                        target: headerChild.parent
                        onClicked: root.checkMandatoryFields = true
                    }
                }
            }

            TextField {
                id: firstNameField
                width: parent.width

                //% "First name"
                label: qsTrId("settings_accounts-la-first_name")

                //% "Enter first name"
                placeholderText: qsTrId("settings_accounts-ph-first_name")

                text: root._selfPerson != null ? root._selfPerson.firstName : ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: lastNameField.focus = true
                errorHighlight: !text && checkMandatoryFields
            }

            TextField {
                id: lastNameField
                width: parent.width

                //% "Last name"
                label: qsTrId("settings_accounts-la-last_name")

                //% "Enter last name"
                placeholderText: qsTrId("settings_accounts-ph-last_name")

                text: root._selfPerson != null ? root._selfPerson.lastName : ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: emailField.focus = true
                errorHighlight: !text && checkMandatoryFields
            }

            TextField {
                id: emailField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly
                validator: RegExpValidator { regExp: root._emailRegex }

                //% "Email address"
                label: qsTrId("settings_accounts-la-email")

                //% "Enter email address"
                placeholderText: qsTrId("settings_accounts-ph-email")

                text: root._selfPerson != null
                      ? root._selectSelfPersonMultiValueField(root._selfPerson.emailDetails, 'address')
                      : ""

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: phoneField.focus = true
                errorHighlight: (!text || !root._emailRegex.test(text)) && checkMandatoryFields
            }

            TextField {
                id: phoneField
                width: parent.width
                inputMethodHints: Qt.ImhDialableCharactersOnly

                //% "Phone number (optional)"
                label: qsTrId("settings_accounts-la-phone_optional")

                //% "Enter phone number (optional)"
                placeholderText: qsTrId("settings_accounts-ph-phone_optional")

                text: root._selfPerson != null
                      ? root._selectSelfPersonMultiValueField(root._selfPerson.phoneDetails, 'number')
                      : ""

                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }

            CountryValueButton {
                id: countryButton

                // TODO: change hardcoded color to upcoming theme error color
                valueColor: countryCode === "" && checkMandatoryFields
                            ? "#ff4d4d"
                            : Theme.highlightColor

                onCountrySelected: {
                    root.focus = true
                }
            }

            ValueButton {
                id: languageButton

                //: Allows language to be selected
                //% "Language:"
                label: qsTrId("settings_accounts-la-language")
                // TODO: change hardcoded color to upcoming theme error color
                valueColor: languageLocale === "" && checkMandatoryFields
                            ? "#ff4d4d"
                            : Theme.highlightColor

                value: languageModel.languageName(languageModel.currentIndex)

                onClicked: {
                    root.focus = true
                    var picker = pageStack.push(languagePickerComponent)
                    picker.languageClicked.connect(function(language, locale) {
                        root.languageLocale = locale
                        languageButton.value = language
                        if (picker === pageStack.currentPage) {
                            pageStack.pop()
                        }
                    })
                }

                LanguageModel {
                    id: languageModel
                }

                Component {
                    id: languagePickerComponent
                    LanguagePickerPage {
                        languageModel: languageModel
                    }
                }
            }

            ValueButton {
                id: birthdayButton

                //: Allows birthday to be selected
                //% "Birthday:"
                label: qsTrId("settings_accounts-la-birthday")
                // TODO: change hardcoded color to upcoming theme error color
                valueColor: (root.birthday == null || isNaN(root.birthday.getTime())) && checkMandatoryFields
                            ? "#ff4d4d"
                            : Theme.highlightColor

                value: root.birthday != null && !isNaN(root.birthday.getTime())
                       ? Format.formatDate(root.birthday, Format.DateLong)
                         //% "Select your birthday"
                       : qsTrId("settings_accounts-bt-select_birthday")

                onClicked: {
                    root.focus = true
                    var defaultBirthday
                    if (root.birthday && !isNaN(root.birthday.getTime())) {
                        defaultBirthday = root.birthday
                    } else {
                        // set a sensible default birthday date rather than the current date
                        defaultBirthday = new Date()
                        defaultBirthday.setFullYear(defaultBirthday.getFullYear() - 20)
                    }
                    var dialog = pageStack.push(datePickerComponent, { date: defaultBirthday, _showYearSelectionFirst: true })
                    dialog.accepted.connect(function() {
                        root.birthday = dialog.date
                        birthdayButton.value = Format.formatDate(root.birthday, Format.DateLong)
                    })
                }

                Component {
                    id: datePickerComponent
                    DatePickerDialog {}
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor

                //: Explains why it's necessary to ask for the user's birthday and country information when creating a Jolla account.
                //% "This information is needed to show appropriate content in the Jolla Store. Some apps or content may be age-restricted or only released in certain areas."
                text: qsTrId("settings_accounts-la-why_ask_for_personal_info")
            }
        }
    }
}
