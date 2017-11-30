import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

Column {
    id: root

    property alias serviceFilter: providerModel.serviceFilter

    signal providerSelected(int index, string providerName)
    signal providerDeselected(int index, string providerName)   // deprecated

    //--- end of public api

    property AccountManager _accountManager: AccountManager {}

    function _isCloudStorageProvider(providerName) {
        var provider = _accountManager.provider(providerName)
        if (provider) {
            var serviceNames = provider.serviceNames
            for (var i=0; i<serviceNames.length; i++) {
                var service = _accountManager.service(serviceNames[i])
                if (service && service.serviceType == "storage") {
                    return true
                }
            }
        }
        return false
    }

    function _isOtherProvider(providerName) {
        return providerName.indexOf("email") == 0
            || providerName.indexOf("onlinesync") == 0
    }

    ProviderModel {
        id: providerModel
    }

    Column {
        width: root.width

        Repeater {
            model: providerModel
            delegate: AccountProviderPickerDelegate {
                width: root.width
                visible: !root._isOtherProvider(model.providerName)
                         && !root._isCloudStorageProvider(model.providerName)
                         && canCreateAccount
            }
        }
    }

    SectionHeader {
        //: List of account providers that offer cloud storage
        //% "Cloud storage"
        text: qsTrId("components_accounts-la-service_name_cloud_storage")
        visible: cloudStorageRepeater.cloudProviderCount > 0
    }

    Column {
        width: root.width

        Repeater {
            id: cloudStorageRepeater
            property int cloudProviderCount
            model: providerModel
            delegate: AccountProviderPickerDelegate {
                id: csPickerDelegate
                width: root.width
                visible: root._isCloudStorageProvider(model.providerName) && canCreateAccount
                Component.onCompleted: {
                    if (root._isCloudStorageProvider(model.providerName)) {
                        cloudStorageRepeater.cloudProviderCount += 1
                    }
                }
            }
        }
    }

    SectionHeader {
        //: List of other types of account providers
        //% "Other"
        text: qsTrId("components_accounts-la-other")
        visible: otherRepeater.otherProviderCount > 0
    }

    Column {
        width: root.width

        Repeater {
            id: otherRepeater
            property int otherProviderCount
            model: providerModel
            delegate: AccountProviderPickerDelegate {
                id: opPickerDelegate
                width: root.width
                visible: root._isOtherProvider(model.providerName) && canCreateAccount
                Component.onCompleted: {
                    if (root._isOtherProvider(model.providerName)) {
                        otherRepeater.otherProviderCount += 1
                    }
                }
            }
        }
    }
}
