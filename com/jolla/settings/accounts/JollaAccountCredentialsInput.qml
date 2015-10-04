import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Column {
    id: root

    property alias username: usernameField.text
    property alias password: passwordField.text

    property int animationDuration: 250
    property int animationEasingType: Easing.Linear

    property bool autoValidate
    property bool highlightInvalidFields

    property bool canValidateCredentials: !busy && username !== ""
            && ((root.state == "signIn" && passwordValidator.hasValidValue && !signInFailed) || (root.state == "createNewAccount" && confirmPasswordValidator.hasValidValue))
    property bool busy: usernameValidator.validating || confirmPasswordValidator.validating || signInFactory.signingIn
    property bool usernameValid: _usernameStatus == AccountFactory.UsernameAvailable
    property bool signInFailed: _signInStatus < 0

    signal signInRequested()
    signal accountSignInSuccess(int accountId)
    signal accountSignInError(string errorMessage)

    property int _usernameStatus: AccountFactory.UsernameNotChecked
    property int _signInStatus: 0   // user/pass sign in validation status. -1 invalid, 0 not checked, 1 ok
    property Flickable _flickable
    property JollaAccountUtilities _jollaAccountUtilities

    function validateNewAccountCredentials() {
        if (root.state == "createNewAccount" && _usernameStatus == AccountFactory.UsernameNotChecked) {
            usernameValidator.validate()
            passwordValidator.validate()
            if (passwordValidator.hasValidValue) {
                confirmPasswordValidator.validate()
            }
        }
    }

    function signIn() {
        if (root.state == "signIn" && _signInStatus <= 0) {
            signInValidator.progressText = ""
            signInFactory.signIn()
        }
    }

    function cancel() {
        _usernameStatus = AccountFactory.UsernameNotChecked
        if (usernameValidator.validating) {
            usernameValidator.clear()
        }

        passwordValidator.clear()
        passwordValidator.progressText = ""

        confirmPasswordValidator.clear()
        confirmPasswordValidator.progressText = ""

        signInValidator.clear()
        signInValidator.progressText = ""
        signInFactory.cancelSignIn()
        _signInStatus = 0
    }

    width: parent.width

    state: "signIn"
    states: [
        State {
            name: "signIn"
            PropertyChanges {
                target: passwordConfirmContainer
                height: 0
                opacity: 0
                enabled: false
            }
            PropertyChanges { target: root; username: ""; password: ""; highlightInvalidFields: false }
            PropertyChanges { target: passwordConfirmField; text: "" }
            StateChangeScript { script: root.cancel() }
        },
        State {
            name: "createNewAccount"
            PropertyChanges {
                target: passwordConfirmContainer
                height: passwordConfirmField.height
            }
            PropertyChanges { target: root; username: ""; password: ""; highlightInvalidFields: false }
            PropertyChanges { target: passwordConfirmField; text: "" }
            StateChangeScript { script: root.cancel() }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                property: "opacity"
                duration: root.animationDuration
                easing.type: root.animationEasingType
            }
            NumberAnimation {
                property: "height"
                duration: root.animationDuration
                easing.type: root.animationEasingType
            }
        }
    ]

    on_UsernameStatusChanged: {
        usernameValidator._updateProgressText()
    }

    Component.onCompleted: {
        var parentItem = root.parent
        while (parentItem) {
            if (parentItem.maximumFlickVelocity && !parentItem.hasOwnProperty('__silica_hidden_flickable')) {
                _flickable = parentItem
                break
            }
            parentItem = parentItem.parent
        }
    }

    Component {
        id: jollaAccountUtilitiesComponent
        JollaAccountUtilities {
            onUsernameCheckFinished: {
                if (usernameValidator.validating) {
                    root._usernameStatus = result
                    usernameValidator.validating = false
                } else {
                    root._usernameStatus == AccountFactory.UsernameNotChecked
                }
            }
        }
    }

    AccountUsernameField {
        id: usernameField
        errorHighlight: (!text && root.highlightInvalidFields)
                        || (root.state == "createNewAccount" && root._usernameStatus != AccountFactory.UsernameAvailable && _usernameStatus != AccountFactory.UsernameNotChecked)
                        || (root.state == "signIn" && root.signInFailed)

        onTextChanged: {
            root._usernameStatus = AccountFactory.UsernameNotChecked
            if (root.state == "signIn" && root.signInFailed) {
                root.cancel()
            }
        }

        EnterKey.enabled: text || inputMethodComposing
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: {
            if (root.state == "createNewAccount") {
                usernameValidator.validateAndFocusNextField(passwordField, false)
            } else if (root.state == "signIn") {
                passwordField.focus = true
            }
        }
    }

    ValidatedTextInput {
        id: usernameValidator

        property bool moveToPasswordFieldWhileValidating

        //: Tells the user that the username availability is being checked
        //% "Checking username availability"
        property string _progressTextChecking: qsTrId("settings_accounts-username_checking_availability")

        hasValidValue: (root.state == "signIn" && username.length > 0)
                       || (root.state == "createNewAccount" && root._usernameStatus === AccountFactory.UsernameAvailable)
        textField: root.state == "createNewAccount" ? usernameField : null
        flickable: _flickable
        autoValidate: root.state == "createNewAccount" && root.autoValidate
        errorHighlight: root.state == "createNewAccount"
                        && root._usernameStatus != AccountFactory.UsernameAvailable
                        && root._usernameStatus != AccountFactory.UsernameNotChecked

        function _updateProgressText() {
            if (root.state != "createNewAccount"
                    || root._jollaAccountUtilities == null) { // validation was canceled
                progressText = ""
                return
            }
            switch (root._usernameStatus) {
            case AccountFactory.UsernameAvailable:
                //: The entered username is available
                //% "Username is available"
                progressText = qsTrId("settings_accounts-la_username_available")
                break
            case AccountFactory.UsernameNotAvailable:
                //: The entered username is not available as it is already taken
                //% "Sorry, this username is already taken"
                progressText = qsTrId("settings_accounts-username_already_taken")
                break
            case AccountFactory.UsernameInvalid:
                //: The entered username is invalid
                //% "A username can only contain letters, numbers, periods, underscores, hyphens and the @ symbol."
                progressText = qsTrId("settings_accounts-la_username_invalid")
                break
            case AccountFactory.UsernameCheckError:
                //: Tells the user that we couldn't check whether the username was available due to network or other error
                //% "Unable to check username availability"
                progressText = qsTrId("settings_accounts-la-username_cannot_check")
                break
            case AccountFactory.UsernameCheckSslError:
                //: The entered username is invalid
                //% "Unable to check username availability. Make sure the system date and time are correct in Settings | System | Date and time."
                progressText = qsTrId("settings_accounts-la_username_ssl_error")
                break
            default:
                progressText = validating ? _progressTextChecking : ""
                break
            }
        }

        onValidationRequested: {
            if (root.state == "createNewAccount"
                    && _usernameStatus == AccountFactory.UsernameNotChecked
                    && usernameField.text != "") {
                validating = true
                if (root._jollaAccountUtilities) {
                    root._jollaAccountUtilities.destroy()
                }
                root._jollaAccountUtilities = jollaAccountUtilitiesComponent.createObject(root)
                root._jollaAccountUtilities.checkUsernameAvailability(usernameField.text)
                progressText = _progressTextChecking
            }
        }

        onValidationCanceled: {
            if (root._jollaAccountUtilities) {
                root._jollaAccountUtilities.destroy()
                root._jollaAccountUtilities = null
                progressText = ""
                _usernameStatus = AccountFactory.UsernameNotChecked
            }
        }
    }

    AccountPasswordField {
        id: passwordField

        errorHighlight: (!text && highlightInvalidFields)
                        || (!passwordValidator.hasValidValue && passwordValidator.progressDisplayed)
                        || (root.state == "signIn" && root.signInFailed)

        onTextChanged: {
            if (root.state == "signIn" && root.signInFailed) {
                root.cancel()
            }
        }

        EnterKey.onClicked: {
            if (root.state == "createNewAccount") {
                passwordValidator.validateAndFocusNextField(passwordConfirmField, true)
            } else if (root.state == "signIn") {
                if (usernameValidator.hasValidValue
                        && passwordValidator.hasValidValue
                        && !root.signInFailed) {
                    root.signInRequested()
                }
            }
        }
    }

    ValidatedTextInput {
        id: passwordValidator

        property bool _passwordTooShort: root.state == "createNewAccount" && password.length <= 5

        hasValidValue: (root.state == "createNewAccount" && passwordField.text && !_passwordTooShort)
                       || (root.state == "signIn" && password.length > 0)
        textField: passwordField
        flickable: _flickable
        autoValidate: root.state == "createNewAccount" && root.autoValidate
        errorHighlight: true

        onValidationRequested: {
            if (root.state == "createNewAccount") {
                if (hasValidValue) {
                    progressText = ""
                } else if (_passwordTooShort) {
                    //% "Password is too short"
                    progressText = qsTrId("settings_accounts-la_password_too_short")
                }
            }
        }
    }

    Item {
        id: passwordConfirmContainer
        width: parent.width
        height: 0
        clip: true

        TextField {
            id: passwordConfirmField
            width: parent.width
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            echoMode: TextInput.Password
            errorHighlight: !text && root.highlightInvalidFields
                            || (!confirmPasswordValidator.hasValidValue && confirmPasswordValidator.progressDisplayed)

            //% "Re-enter password"
            label: qsTrId("settings_accounts-la-password_confirm")

            //% "Re-enter password"
            placeholderText: qsTrId("settings_accounts-ph-password_confirm")

            EnterKey.enabled: text || inputMethodComposing
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: {
                confirmPasswordValidator.validate()
                if (confirmPasswordValidator.hasValidValue) {
                    root.focus = true
                }
            }
        }
    }

    ValidatedTextInput {
        id: confirmPasswordValidator

        hasValidValue: root.state == "createNewAccount" && passwordField.text === passwordConfirmField.text

        textField: passwordConfirmField
        flickable: _flickable
        autoValidate: root.state == "createNewAccount" && root.autoValidate && passwordField.text !== ""
        errorHighlight: true

        onValidationRequested: {
            if (root.state == "createNewAccount") {
                if (hasValidValue) {
                    progressText = ""
                } else {
                    //: User has to enter the new password twice. If the second value does not match the first, this error is shown.
                    //% "Passwords do not match"
                    progressText = qsTrId("settings_accounts-la_passwords_do_not_match")
                }
            }
        }
    }

    // This doesn't auto-validate; it is used to show an error when sign-in fails.
    ValidatedTextInput {
        id: signInValidator
        autoValidate: false
        errorHighlight: true
    }

    AccountFactory {
        id: signInFactory
        property bool signingIn
        property string lastErrorText

        function signIn() {
            lastErrorText = ""
            signingIn = true
            createExistingJollaAccount(root.username, root.password, "Jolla", "Jolla")
        }

        function cancelSignIn() {
            if (signingIn) {
                cancel()
            }
            signingIn = false
        }

        onError: {
            console.log("Jolla account sign-in error:", errorCode, message)
            if (signingIn) {   // in case validation was cancelled in UI
                if (errorCode == AccountFactory.LoginError) {
                    //% "Entered username or password was not valid"
                    lastErrorText = qsTrId("settings_accounts-la_sign_in_bad_credentials")
                } else if (errorCode == AccountFactory.UnknownError || errorCode == AccountFactory.InternalError) {
                     // the error message won't be human-readable, so show a generic error
                    //% "Unable to log in with this username and password"
                    lastErrorText = qsTrId("settings_accounts-la_sign_in_error")
                } else {
                    // the error message should be human readable
                    lastErrorText = message
                }
                signInValidator.progressText = lastErrorText
            }
            signingIn = false
            _signInStatus = -1
            root.accountSignInError(message)
        }
        onSuccess: {
            signingIn = false
            _signInStatus = 1
            root.accountSignInSuccess(newAccountId)
        }
    }
}
