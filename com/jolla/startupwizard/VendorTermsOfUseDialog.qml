import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0

TermsOfUseDialog {
    id: root

    readonly property variant strings: startupWizardManager.vendorTermsSummary(localeName)

    party: StartupWizardManager.Vendor

    function _string(index) { return strings && strings.length > index ? strings[index] : "" }

    headerText: _string(0)
    summaryText: _string(1)
    linkText: _string(2)
    rejectLinkText: _string(3)
    rejectHeaderText: _string(4)
    rejectBodyText: _string(5)
}
