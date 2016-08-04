import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0

TermsOfUseDialog {
    id: root

    party: StartupWizardManager.SailfishOS

    headerText: {
        //% "End User License Agreement"
        qsTrId("startupwizard-he-eula") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-he-eula", root.localeName)
    }
    summaryText: {
        //: %1 = a copy of the translated text of startupwizard-he-agree
        //% "This device runs Sailfish OS. By selecting '%1' and starting to use Sailfish OS you agree to the Sailfish OS End User License Agreement."
        qsTrId("startupwizard-la-sailfish_eula_intro") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-sailfish_eula_intro", root.localeName)
                .arg(dialogHeader.acceptText)
    }
    linkText: {
        //: Text surrounded by %1 and %2 is underlined and colored differently
        //% "Please read the %1Sailfish OS End User License Agreement%2 carefully before accepting."
        qsTrId("startupwizard-la-sailfish_eula_read_carefully") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-sailfish_eula_read_carefully", root.localeName)
    }
    rejectLinkText: {
        //: Text surrounded by %1 and %2 is underlined and colored differently
        //% "%1Reject the Sailfish OS End User License Agreement%2 and turn the device off"
        qsTrId("startupwizard-la-reject_sailfish_eula_and_turn_off") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-reject_sailfish_eula_and_turn_off", root.localeName)
    }
    rejectHeaderText: {
        //% "Are you sure you want to reject the Sailfish OS End User License Agreement?"
        qsTrId("startupwizard-he-reject_eula_heading_text") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-he-reject_eula_heading_text", root.localeName)
    }
    rejectBodyText: {
        //% "If you cannot accept the terms of this Agreement after having purchased a product incorporating Software, please return the product containing the Software to the seller in accordance with the applicable return policy."
        qsTrId("startupwizard-la-reject_eula_body_text") // trigger Qt Linguist translation
        return startupWizardManager.translatedText("startupwizard-la-reject_eula_body_text", root.localeName)
    }
}
