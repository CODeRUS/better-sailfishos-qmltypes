import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Timezone 1.0
import com.jolla.settings.accounts 1.0
import MeeGo.QOfono 0.2

ValueButton {
    id: root

    property string countryCode
    property string countryName

    property bool _defaultCountrySet

    signal countrySelected(string countryName, string countryCode)

    //: Allows country to be selected
    //% "Country:"
    label: qsTrId("settings_accounts-la-country")

    value: countryName
           ? countryName
             //: Select the country that the user is currently in
             //% "Select country"
           : qsTrId("settings_accounts-la-select_country")

    onClicked: {
        var picker = pageStack.push(countryPickerComponent)
        picker.countryClicked.connect(function(countryName, countryCode) {
            root.countryCode = countryCode
            root.countryName = countryName
            root.countrySelected(countryName, countryCode)
            if (picker === pageStack.currentPage) {
                pageStack.pop()
            }
        })
    }

    CountryModel {
        id: countryModel
    }

    JollaAccountUtilities {
        id: jollaAccountUtil
    }

    OfonoManager {
        id: ofonoManager
    }

    OfonoSimManager {
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""

        onMobileCountryCodeChanged: {
            if (!root._defaultCountrySet) {
                var alphaCountryCode = jollaAccountUtil.mobileCountryCodeToAlpha2CountryCode(mobileCountryCode)
                if (alphaCountryCode.length) {
                    var name = countryModel.countryName(countryModel.indexOf(alphaCountryCode))
                    if (name.length) {
                        root.countrySelected(name, alphaCountryCode)
                    }
                }
            }
            root._defaultCountrySet = true
        }
    }

    Component {
        id: countryPickerComponent
        CountryPicker {
            model: countryModel
        }
    }
}
