import QtQuick 2.0
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
    property var endDestinationAction: PageStackAction.Push
    property var endDestinationProperties: ({})
    property var endDestinationReplaceTarget: undefined

    property Dialog _sailfishAppInstallationDialog
    property Dialog _androidAppsInstallDialog

    property bool _selectedAppsToInstall: ((_sailfishAppInstallationDialog && _sailfishAppInstallationDialog.selectedAppCount > 0) ||
                                           (_androidAppsInstallDialog && _androidAppsInstallDialog.selectedAppCount > 0))

    property bool _skipAppPage: sailfishAppSelectionSuppressed.value == true || !policy.value
    property bool _skipAndroidPage: androidSelectionSuppressed.value == true || !policy.value

    Component.onCompleted: {
        if (!_skipAppPage) {
            _sailfishAppInstallationDialog = applicationInstallationComponent.createObject(root)
        }
        if (!_skipAndroidPage) {
            _androidAppsInstallDialog = androidInstallationComponent.createObject(root)
        }
    }

    acceptDestination: _skipAppPage ? (_skipAndroidPage ? root.endDestination : root._androidAppsInstallDialog)
                                    : root._sailfishAppInstallationDialog
    acceptDestinationAction: _skipAppPage ? (_skipAndroidPage ? root.endDestinationAction : PageStackAction.Push)
                                          : PageStackAction.Push
    acceptDestinationProperties: _skipAppPage ? (_skipAndroidPage ? root.endDestinationProperties : undefined)
                                              : undefined
    acceptDestinationReplaceTarget: acceptDestination == root.endDestination ? root.endDestinationReplaceTarget : undefined

    StartupApplicationModel {
        id: sailfishAppsModel
        category: "jolla"
    }

    StartupApplicationModel {
        id: androidAppsModel
        category: "marketplace"

        Component.onCompleted: {
            populate(accountManager.getProviderList())
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
    }

    ConfigurationValue {
        id: androidSelectionSuppressed
        key: "/apps/jolla-startupwizard/android_selection_suppressed"
    }
}
