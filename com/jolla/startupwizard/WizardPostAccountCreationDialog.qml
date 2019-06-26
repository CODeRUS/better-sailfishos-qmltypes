import QtQuick 2.0
import QtQml.Models 2.1
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import org.nemomobile.configuration 1.0
import Sailfish.Accounts 1.0
import Sailfish.Store 1.0
import Sailfish.Policy 1.0

Dialog {
    id: root

    property bool runningFromSettingsApp

    property var endDestination
    property int endDestinationAction: PageStackAction.Push
    property var endDestinationProperties: ({})
    property var endDestinationReplaceTarget: undefined

    property Dialog _sailfishAppInstallationDialog
    property Dialog _androidAppsInstallDialog

    property bool _selectedAppsToInstall: ((_sailfishAppInstallationDialog && _sailfishAppInstallationDialog.selectedAppCount > 0) ||
                                           (_androidAppsInstallDialog && _androidAppsInstallDialog.selectedAppCount > 0))

    property bool _skipAppPage: !_sailfishAppInstallationAllowed || !_sailfishAppInstallationDialog
    property bool _skipAndroidPage: !_androidAppInstallationAllowed || !_androidAppsInstallDialog

    readonly property bool _sailfishAppInstallationAllowed: !sailfishAppSelectionSuppressed.value && policy.value
    readonly property bool _androidAppInstallationAllowed: !androidSelectionSuppressed.value && policy.value

    canAccept: sailfishAppsModel.populated && androidAppsModel.populated && androidAppsModel.androidSupportStatus != StartupApplicationModel.Unknown
    acceptDestination: {
        if (canAccept) {
            _skipAppPage ? (_skipAndroidPage ? root.endDestination : root._androidAppsInstallDialog)
                         : root._sailfishAppInstallationDialog
        } else {
            return null
        }
    }
    acceptDestinationAction: _skipAppPage ? (_skipAndroidPage ? root.endDestinationAction : PageStackAction.Push)
                                          : PageStackAction.Push
    acceptDestinationProperties: _skipAppPage ? (_skipAndroidPage ? root.endDestinationProperties : undefined)
                                              : undefined
    acceptDestinationReplaceTarget: acceptDestination == root.endDestination ? root.endDestinationReplaceTarget : undefined

    StartupApplicationModel {
        id: sailfishAppsModel
        category: "jolla"

        onPopulatedChanged: {
            if (_sailfishAppInstallationAllowed && populated && count > 0) {
                _sailfishAppInstallationDialog = applicationInstallationComponent.createObject(root)
            }
        }
    }

    StartupApplicationModel {
        id: androidAppsModel

        readonly property bool createAndroidAppInstallationDialog: (androidSupportStatus == StartupApplicationModel.Installed && count > 0) || androidSupportPackageAvailable
        property bool androidSupportPackageAvailable

        function isAndroidSupportPackage(packageName) {
            return packageName == "aliendalvik"
        }

        category: "marketplace"

        onPopulatedChanged: {
            if (_androidAppInstallationAllowed && populated && count > 0) {
                delegateModel.model = androidAppsModel
            }
        }

        onCreateAndroidAppInstallationDialogChanged: {
            if (createAndroidAppInstallationDialog && !_androidAppsInstallDialog) {
                _androidAppsInstallDialog = androidInstallationComponent.createObject(root)
            }
        }

        Component.onCompleted: populate(accountManager.getProviderList())
    }

    DelegateModel {
        id: delegateModel
        delegate: QtObject {}
        onCountChanged: {
            var androidSupportPackageAvailable = false
            for (var i = 0; i < items.count; ++i) {
                if (androidAppsModel.isAndroidSupportPackage(items.get(i).model.packageName)) {
                    androidSupportPackageAvailable = true
                    break
                }
            }
            androidAppsModel.androidSupportPackageAvailable = androidSupportPackageAvailable
        }
    }


    AccountManager {
        id: accountManager

        function getProviderList() {
            var providerList = []
            for (var i = 0; i < accountManager.accountIdentifiers.length; ++i) {
                var account = accountManager.account(accountManager.accountIdentifiers[i])
                if (providerList.indexOf(account.providerName) === -1) {
                    providerList.push(account.providerName)
                }
            }
            return providerList
        }
    }

    PolicyValue {
        id: policy
        policyType: PolicyValue.ApplicationInstallationEnabled
    }

    Column {
        id: accountSuccessfullyCreatedView
        width: parent.width

        WizardDialogHeader {
            //: Displayed when Jolla account creation or sign-in was successful
            //% "Great, your Jolla account was successfully added!"
            title: qsTrId("startupwizard-he-great_your_jolla_account_was_added")
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            height: implicitHeight + Theme.paddingLarge*2
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            visible: !root.runningFromSettingsApp

            //% "You can find your Jolla account later from Settings | Accounts."
            text: qsTrId("startupwizard-la-other_accounts_setup_later_from_settings")
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://theme/graphic-store-jolla-apps"
        }

    }

    Item {
        anchors {
            top: accountSuccessfullyCreatedView.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: Theme.paddingLarge

            Label {
                //: Displayed the same time with "Great! your Jolla was successfully added!", and we might be fetching more than just one application.
                //% "Fetching applications to install"
                text: qsTrId("startupwizard-la-fetching_application_information")
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin*2
                opacity: busyIndicator.opacity
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: Theme.highlightColor
            }

            BusyIndicator {
                id: busyIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                size: BusyIndicatorSize.Large
                running: !root.canAccept
            }
        }
    }

    Component {
        id: applicationInstallationComponent

        ApplicationInstallationDialog {
            acceptDestination: _skipAndroidPage ? (_selectedAppsToInstall ? appInstallationConfirmationComponent : root.endDestination) : root._androidAppsInstallDialog
            acceptDestinationAction: _skipAndroidPage ? (_selectedAppsToInstall ? PageStackAction.Push : root.endDestinationAction) : PageStackAction.Push
            acceptDestinationProperties: _skipAndroidPage ? (_selectedAppsToInstall ? undefined : root.endDestinationProperties) : undefined
            acceptDestinationReplaceTarget: acceptDestination == root.endDestination ? root.endDestinationReplaceTarget : undefined

            applicationModel: sailfishAppsModel
        }
    }

    Component {
        id: androidInstallationComponent

        AndroidInstallationDialog {
            acceptDestination: _selectedAppsToInstall ? appInstallationConfirmationComponent : root.endDestination
            acceptDestinationAction: _selectedAppsToInstall ? PageStackAction.Push : root.endDestinationAction
            acceptDestinationProperties: _selectedAppsToInstall ? undefined : root.endDestinationProperties
            acceptDestinationReplaceTarget: acceptDestination == root.endDestination ? root.endDestinationReplaceTarget : undefined

            applicationModel: androidAppsModel
        }
    }

    Component {
        id: appInstallationConfirmationComponent

        Dialog {
            //: Displayed just before the tutorial to teach how to use Sailfish OS
            //% "Great! Next you'll learn to use Sailfish OS"
            property string _textOnwardsToTutorial: qsTrId("startupwizard-he-great_next_learn_to_use_sailfish_os")

            //% "Your apps are downloading and installing in the background."
            property string _textAppsDownloading: qsTrId("startupwizard-la-your_apps_are_installing_in_background")

            acceptDestination: root.endDestination
            acceptDestinationAction: root.endDestinationAction
            acceptDestinationProperties: root.endDestinationProperties
            acceptDestinationReplaceTarget: root.endDestinationReplaceTarget

            Column {
                width: parent.width

                WizardDialogHeader {
                    id: header
                    title: root.runningFromSettingsApp ? _textAppsDownloading : _textOnwardsToTutorial
                }

                Label {
                    id: bodyLabel
                    x: Theme.horizontalPageMargin
                    width: parent.width - x*2
                    height: implicitHeight + Theme.paddingLarge*3
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                    visible: text !== ""
                    text: root.runningFromSettingsApp ? "" : _textAppsDownloading
                }

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "image://theme/graphic-store-jolla-apps"
                }
            }
        }
    }

    ConfigurationValue {
        id: sailfishAppSelectionSuppressed
        key: "/apps/jolla-startupwizard/sailfish_app_selection_suppressed"
        defaultValue: false
    }

    ConfigurationValue {
        id: androidSelectionSuppressed
        key: "/apps/jolla-startupwizard/android_selection_suppressed"
        defaultValue: false
    }
}
