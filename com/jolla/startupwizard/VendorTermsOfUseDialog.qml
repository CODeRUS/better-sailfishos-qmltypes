import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0

TermsOfUseDialog {
    id: root

    readonly property variant strings: termsOfUseManager.vendorTermsSummary(localeName)

    party: StartupWizardManager.Vendor

    function _string(index) {
        if (strings && strings.length > index) {
            return strings[index]
        }
        console.log("index", index, "exceeds terms string list length", strings.length)
        return ""
    }

    function loadFullTermsOfUse(localeName) {
        return termsOfUseManager.vendorTermsOfUse(localeName)
    }

    headerText: _string(0)
    summaryText: _string(1)
    linkText: _string(2)
    rejectLinkText: _string(3)
    rejectHeaderText: _string(4)
    rejectBodyText: _string(5)
}
